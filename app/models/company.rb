# frozen_string_literal: true

# == Schema Information
#
# Table name: companies
#
#  id                    :bigint           not null, primary key
#  token                 :string
#  name                  :string
#  address               :string
#  formatted_address     :string
#  area                  :string
#  lat                   :decimal(9, 6)
#  lng                   :decimal(9, 6)
#  hq_country            :string
#  description           :string
#  avatar_data           :text
#  disabled              :boolean          default(TRUE), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  messages_count        :integer          default(0), not null
#  company_reviews_count :integer          default(0), not null
#  profile_header_data   :text
#  contract_preference   :string           default(NULL)
#  job_markets           :citext
#  technical_skill_tags  :citext
#  profile_views         :integer          default(0), not null
#  website               :string
#  phone_number          :string
#  number_of_offices     :integer          default(0)
#  number_of_employees   :string
#  established_in        :integer
#  header_color          :string           default("FF6C38")
#  country               :string
#  header_source         :string           default("default")
#  sales_tax_number      :string
#  line2                 :string
#  city                  :string
#  state                 :string
#  postal_code           :string
#  job_types             :citext
#  manufacturer_tags     :citext
#  registration_step     :string
#  saved_drivers_ids     :citext
#

# rubocop:disable Metrics/ClassLength
class Company < ApplicationRecord

  audited

  extend Enumerize
  include PgSearch
  include Geocodable
  include Disableable
  include AvatarUploader[:avatar]
  include ProfileHeaderUploader[:profile_header]

  has_many :jobs, -> { order(updated_at: :desc) }, dependent: :destroy
  has_many :applicants, dependent: :destroy
  has_many :messages, -> { order(created_at: :desc) }, as: :authorable
  has_many :driver_reviews, dependent: :nullify
  has_many :company_reviews, dependent: :destroy
  has_many :featured_projects, dependent: :destroy
  has_many :favourites
  has_many :favourite_drivers, through: :favourites, source: :driver
  has_many :company_installs, dependent: :destroy
  has_many :notifications, as: :receivable, dependent: :destroy
  has_one :company_user, dependent: :destroy

  attr_accessor :accept_terms_of_service, :accept_privacy_policy, :accept_code_of_conduct,
                :enforce_profile_edit, :user_type

  validates :phone_number, length: { minimum: 7 }, allow_blank: true
  validates :name, :country, :city, :website, :area, presence: true, on: :update, if: :step_job_info?

  enumerize :contract_preference, in: %i[prefer_fixed prefer_hourly prefer_daily]

  enumerize :number_of_employees, in: %i[
    one_to_ten
    eleven_to_one_hundred
    one_hundred_one_to_one_thousand
    more_than_one_thousand
  ]

  serialize :job_markets
  serialize :technical_skill_tags
  serialize :manufacturer_tags
  serialize :saved_drivers_ids, Array

  enumerize :country, in: %i[
    at au be ca ch de dk es fi fr gb hk ie it jp lu nl no nz pt se sg us
  ]

  enumerize :header_source, in: %i[
    color
    wallpaper
    default
  ]

  accepts_nested_attributes_for :featured_projects, allow_destroy: true, reject_if: :reject_featured_projects
  accepts_nested_attributes_for :company_installs, allow_destroy: true, reject_if: :reject_company_installs
  accepts_nested_attributes_for :company_user

  scope :new_registrants, -> { where(disabled: true, registration_step: "wicked_finish") }
  scope :incomplete_registrations, -> { where.not(registration_step: "wicked_finish") }

  before_create :set_default_step
  after_save :send_confirmation_email

  def messages_for_driver(driver)
    Message.messages_for(self, driver)
  end

  def drivers_for_messaging
    all_messages = messages.to_a + Message.where(receivable_type: "Company", receivable_id: id).to_a
    all_messages.sort_by(&:created_at).reverse
                .map { |msg| msg.authorable.is_a?(Driver) ? msg.authorable : msg.receivable }.uniq
  end

  def new_messages_from_driver?(driver)
    notifications.where(authorable: driver, read_at: nil).count.positive?
  end

  def drivers
    Driver.where(id: saved_drivers_ids)
  end

  def hired_drivers
    Driver
      .joins(:driver_profile, applicants: :job)
      .where(jobs: { company_id: id })
      .where(applicants: { state: :accepted })
      .order(first_name: :desc, last_name: :desc)
  end

  def city_state_province
    "#{city}#{", #{state}" unless state.blank?}"
  end

  def postal_code_country
    "#{"#{postal_code}, " unless postal_code.blank?}#{I18n.t("enumerize.country.#{country}")}"
  end

  def open_jobs
    jobs.where(state: :published)
  end

  def renew_month
    self.expires_at = Date.today + 1.month
  end

  def renew_year
    self.expires_at = Date.today + 1.year
  end

  def job_types
    has_system_integration = system_integration_job_markets?
    has_live_events_staging_and_rental = live_events_staging_and_rental_job_markets?

    if has_live_events_staging_and_rental && has_system_integration
      return "System Integration & Live Events Staging And Rental"
    end

    if has_system_integration
      "System Integration"
    elsif has_live_events_staging_and_rental
      "Live Events Staging And Rental"
    else
      "None"
    end
  end

  def system_integration_job_markets?
    I18n.t("enumerize.system_integration_job_markets").each do |key, _|
      return true if job_markets.present? && job_markets[key] == "1"
    end
    false
  end

  def live_events_staging_and_rental_job_markets?
    I18n.t("enumerize.live_events_staging_and_rental_job_markets").each do |key, _|
      return true if job_markets.present? && job_markets[key] == "1"
    end
    false
  end

  validates_presence_of :name,
                        :address,
                        :city,
                        :postal_code,
                        :area,
                        :country,
                        :description,
                        :established_in,
                        if: :enforce_profile_edit

  pg_search_scope :search, against: {
    name: "A",
    area: "B",
    job_markets: "B",
    technical_skill_tags: "B",
    manufacturer_tags: "B",
    formatted_address: "C",
    description: "C",
  }, associated_against: {
    company_user: %i[email first_name last_name],
  }, using: {
    tsearch: { prefix: true },
  }

  pg_search_scope :name_or_email_search, against: {
    name: "A",
  }, associated_against: {
    company_user: [:email],
  }, using: {
    tsearch: { prefix: true },
  }

  def rating
    return unless company_reviews.count.positive?

    # rubocop:disable Metrics/LineLength
    company_reviews.average("(#{CompanyReview::RATING_ATTRS.map(&:to_s).join('+')}) / #{CompanyReview::RATING_ATTRS.length}").round
    # rubocop:enable Metrics/LineLength
  end

  def self.avg_rating(company)
    return nil if company.company_reviews_count.zero?

    company.rating
  end

  after_save :check_if_should_do_geocode

  def check_if_should_do_geocode
    # rubocop:disable Metrics/LineLength
    unless saved_changes.include?("address") || saved_changes.include?("city") || (!address.nil? && lat.nil?) || (!city.nil? && lat.nil?)
      return
    end

    # rubocop:enable Metrics/LineLength
    do_geocode
    update_columns(formatted_address: formatted_address, lat: lat, lng: lng)
  end

  def reject_featured_projects(attrs)
    exists = attrs["id"].present?
    (empty = attrs["file"].blank?) && attrs["name"].blank?
    !exists && empty
  end

  def reject_company_installs(attrs)
    exists = attrs["id"].present?
    (empty = attrs["year"].blank?) && attrs["installs"].blank
    !exists && empty
  end

  def job_markets_for_job_type(job_type)
    all_job_markets = I18n.t("enumerize.#{job_type}_job_markets")
    return [] unless all_job_markets.is_a?(Hash)

    driver_job_markets = []
    job_markets&.each do |index, _value|
      driver_job_markets << all_job_markets[index.to_sym] if all_job_markets[index.to_sym]
    end
    driver_job_markets
  end

  def canada_country?
    country == "ca"
  end

  def self.do_all_geocodes
    Company.all.each do |company|
      p "Doing geocode for " + company.id.to_s + "(#{company.compile_address})"
      company.do_geocode
      company.update_columns(lat: company.lat, lng: company.lng)

      sleep 1
    end
  end

  def registration_completed?
    registration_step == "wicked_finish"
  end

  def full_name
    name
  end

  def first_name_and_initial
    name
  end

  def user_data
    self
  end

  def saved_driver?(driver)
    saved_drivers_ids.include?(driver.id)
  end

  def owner
    company_user
  end

  private

  def step_job_info?
    registration_step == "job_info"
  end

  def set_default_step
    self.registration_step ||= "personal"
  end

  def send_confirmation_email
    return if owner&.confirmed? || !registration_completed? || owner&.confirmation_sent_at.present?

    owner&.send_confirmation_instructions
    owner&.update_column(:confirmation_sent_at, Time.current)
  end

  protected

  def confirmation_required?
    registration_completed?
  end

  # This SQL needs to stay exactly in sync with it's related index (index_on_companies_location)
  # otherwise the index won't be used. (don't even add whitespace!)
  # https://github.com/pairshaped/postgis-on-rails-example
  # scope :near, -> (lat, lng, distance_in_meters = 2000) {
  #   where(%{
  #     ST_DWithin(
  #       ST_GeographyFromText(
  #         'SRID=4326;POINT(' || companies.lng || ' ' || companies.lat || ')'
  #       ),
  #       ST_GeographyFromText('SRID=4326;POINT(%f %f)'),
  #       %d
  #     )
  #   } % [lng, lat, distance_in_meters])
  # }

end
# rubocop:enable Metrics/ClassLength
