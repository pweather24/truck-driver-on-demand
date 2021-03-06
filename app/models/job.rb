# frozen_string_literal: true

# == Schema Information
#
# Table name: jobs
#
#  id                   :bigint           not null, primary key
#  company_id           :bigint           not null
#  title                :string
#  state                :string           default("created"), not null
#  summary              :text
#  technical_skill_tags :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  address              :string
#  lat                  :decimal(9, 6)
#  lng                  :decimal(9, 6)
#  formatted_address    :string
#  country              :string
#  job_markets          :citext
#  manufacturer_tags    :citext
#  state_province       :string
#

class Job < ApplicationRecord

  extend Enumerize
  include Geocodable
  include PgSearch
  include EasyPostgis

  belongs_to :company
  has_many :applicants, -> { includes(:driver).order(updated_at: :desc) }, dependent: :destroy
  has_many :messages, dependent: :nullify
  has_many :change_orders, -> { order(updated_at: :desc) }, dependent: :destroy
  has_many :attachments, dependent: :destroy
  has_one :driver_review, dependent: :nullify
  has_one :company_review, dependent: :nullify
  has_many :job_invites
  has_many :job_collaborators, dependent: :destroy

  accepts_nested_attributes_for :attachments, allow_destroy: true, reject_if: :reject_attachments

  attr_accessor :save_draft

  after_save :check_if_should_do_geocode

  enumerize :country, in: %i[
    at au be ca ch de dk es fi fr gb hk ie it jp lu nl no nz pt se sg us
  ]

  enumerize :state, in: %i[
    created
    published
    completed
  ], predicates: true, scope: true

  validates :title, :summary, :address, :country, presence: true, if: :published?

  serialize :technical_skill_tags
  serialize :manufacturer_tags
  serialize :job_markets

  pg_search_scope :search, against: {
    title: "A",
    job_markets: "B",
    technical_skill_tags: "B",
    manufacturer_tags: "B",
    summary: "C",
  }, using: {
    tsearch: { prefix: true, any_word: true },
  }

  def published?
    state != :created
  end

  def repliers
    driver_ids = messages.where(receivable_type: "Company").pluck(:authorable_id).uniq
    Driver.where(id: driver_ids)
  end

  def city_state_country
    str = ""
    str += "#{address}, " if address.present?
    str += "#{CS.states(country.to_sym)[state_province.to_sym]}, " if state_province.present?
    str += country.upcase.to_s if country.present?
    str
  end

  def self.all_job_functions
    I18n.t("enumerize.system_integration_job_functions")
        .merge(I18n.t("enumerize.live_events_staging_and_rental_job_functions"))
  end

  def self.all_job_markets
    I18n.t("enumerize.system_integration_job_markets")
        .merge(I18n.t("enumerize.live_events_staging_and_rental_job_markets"))
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def matches(distance = nil)
    if system_integration_job_markets? && live_events_staging_and_rental_job_markets?
      system_integration_job_markets = I18n.t("enumerize.system_integration_job_markets").keys.map { |val| "%#{val}%" }
      live_events_staging_and_rental_job_markets = I18n.t("enumerize.live_events_staging_and_rental_job_markets")
                                                       .keys.map { |val| "%#{val}%" }
      job_markets = system_integration_job_markets + live_events_staging_and_rental_job_markets
      driver_profiles = DriverProfile.where(disabled: false)
                                     .where("job_markets ilike any ( array[?] )", job_markets)
    elsif system_integration_job_markets?
      job_markets = I18n.t("enumerize.system_integration_job_markets").keys.map { |val| "%#{val}%" }
      driver_profiles = DriverProfile.where(disabled: false)
                                     .where("job_markets ilike any ( array[?] )", job_markets)
    elsif live_events_staging_and_rental_job_markets?
      job_markets = I18n.t("enumerize.live_events_staging_and_rental_job_markets").keys.map { |val| "%#{val}%" }
      driver_profiles = DriverProfile.where(disabled: false)
                                     .where("job_markets ilike any ( array[?] )", job_markets)
    else
      driver_profiles = DriverProfile.where(disabled: false)
    end
    address_for_geocode = address
    address_for_geocode += ", #{CS.states(country.to_sym)[state_province.to_sym]}" if state_province.present?
    address_for_geocode += ", #{CS.countries[country.upcase.to_sym]}" if country.present?

    # check for cached version of address
    if Rails.cache.read(address_for_geocode)
      geocode = Rails.cache.read(address_for_geocode)
    else
      # save cached version of address
      do_geocode
      geocode = { address: formatted_address, lat: lat, lng: lng }
      Rails.cache.write(address_for_geocode, geocode) if geocode[:lat] && geocode[:lng]
    end

    if geocode[:lat] && geocode[:lng]
      point = OpenStruct.new(lat: geocode[:lat], lng: geocode[:lng])
      distance = 160_934 if distance.nil?
      driver_profiles = driver_profiles.nearby(geocode[:lat], geocode[:lng], distance)
                                       .with_distance(point)
                                       .order("verified DESC, profile_score DESC, distance")
      Driver.where(id: driver_profiles.map(&:driver_id))
    else
      Driver.none
    end
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

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

  private

  def check_if_should_do_geocode
    return unless saved_changes.include?("address") || (!address.nil? && lat.nil?)

    do_geocode
    update_columns(lat: lat, lng: lng)
  end

end
