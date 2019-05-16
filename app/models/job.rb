# == Schema Information
#
# Table name: jobs
#
#  id                                     :integer          not null, primary key
#  company_id                             :integer          not null
#  title                                  :string
#  state                                  :string           default("created"), not null
#  summary                                :text
#  scope_of_work                          :text
#  budget                                 :decimal(10, 2)
#  job_function                           :string
#  starts_on                              :date
#  ends_on                                :date
#  duration                               :integer
#  pay_type                               :string
#  freelancer_type                        :string
#  technical_skill_tags                   :text
#  invite_only                            :boolean          default(FALSE), not null
#  scope_is_public                        :boolean          default(TRUE), not null
#  budget_is_public                       :boolean          default(FALSE), not null
#  working_days                           :text             default([]), not null, is an Array
#  working_time                           :string
#  contract_price                         :decimal(10, 2)
#  payment_schedule                       :jsonb            not null
#  reporting_frequency                    :string
#  require_photos_on_updates              :boolean          default(FALSE), not null
#  require_checkin                        :boolean          default(FALSE), not null
#  require_uniform                        :boolean          default(FALSE), not null
#  addendums                              :text
#  applicants_count                       :integer          default(0), not null
#  messages_count                         :integer          default(0), not null
#  created_at                             :datetime         not null
#  updated_at                             :datetime         not null
#  currency                               :string
#  address                                :string
#  lat                                    :decimal(9, 6)
#  lng                                    :decimal(9, 6)
#  formatted_address                      :string
#  contract_sent                          :boolean          default(FALSE)
#  opt_out_of_freelance_service_agreement :boolean          default(FALSE)
#  country                                :string
#  scope_file_data                        :text
#  applicable_sales_tax                   :decimal(10, 2)
#  stripe_charge_id                       :string
#  stripe_balance_transaction_id          :string
#  funds_available_on                     :integer
#  funds_available                        :boolean          default(FALSE)
#  job_type                               :citext
#  job_market                             :citext
#  manufacturer_tags                      :citext
#  company_plan_fees                      :decimal(10, 2)   default(0.0)
#  contracted_at                          :datetime
#  state_province                         :string
#  creation_step                          :string
#  plan_fee                               :decimal(10, 2)   default(0.0)
#  paid_by_company                        :boolean          default(FALSE)
#  total_amount                           :decimal(10, 2)
#  tax_amount                             :decimal(10, 2)
#  stripe_fees                            :decimal(10, 2)
#  amount_subtotal                        :decimal(10, 2)
#  variable_pay_type                      :string
#  overtime_rate                          :decimal(10, 2)
#  payment_terms                          :integer
#  expired                                :boolean          default(FALSE)
#  fee_schema                             :json
#  creator_id                             :integer
#
# Indexes
#
#  index_jobs_on_company_id         (company_id)
#  index_jobs_on_creator_id         (creator_id)
#  index_jobs_on_manufacturer_tags  (manufacturer_tags)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#  fk_rails_...  (creator_id => users.id)
#

class Job < ApplicationRecord
  extend Enumerize
  include Geocodable
  include PgSearch
  include EasyPostgis
  include ScopeFileUploader[:scope_file]

  belongs_to :company
  has_many :applicants, -> { includes(:freelancer).order(updated_at: :desc) }, dependent: :destroy
  has_many :messages, -> { order(created_at: :desc) }, as: :receivable
  has_many :change_orders, -> { order(updated_at: :desc) }, dependent: :destroy
  has_many :attachments, dependent: :destroy
  has_one :freelancer_review, dependent: :nullify
  has_one :company_review, dependent: :nullify
  has_many :job_invites
  has_many :job_collaborators, dependent: :destroy

  accepts_nested_attributes_for :attachments, allow_destroy: true, reject_if: :reject_attachments

  attr_accessor :send_contract, :accepted_applicant_id, :enforce_contract_creation, :save_draft

  after_save :check_if_should_do_geocode

  enumerize :job_type, in: I18n.t('enumerize.job_types').keys

  enumerize :working_time, in: [
    :standard_workday,
    :evenings,
    :weekend,
    :any_time
  ]

  enumerize :pay_type, in: I18n.t('enumerize.job.pay_type').keys

  enumerize :variable_pay_type, in: [ :hourly, :daily ]

  enumerize :freelancer_type, in: [ :independent, :service_provider ]

  enumerize :country, in: [
    :at, :au, :be, :ca, :ch, :de, :dk, :es, :fi, :fr, :gb, :hk, :ie, :it, :jp, :lu, :nl, :no, :nz, :pt, :se, :sg, :us
  ]

  enumerize :state, in: [
    :created,
    :published
  ], predicates: true, scope: true

  validates :title, :summary, :address, :country, presence: true, if: :is_published?

  schema_validations except: :working_days

  serialize :technical_skill_tags
  serialize :manufacturer_tags
  serialize :job_market

  audited

  pg_search_scope :search, against: {
    title: "A",
    job_type: "B",
    job_market: "B",
    technical_skill_tags: "B",
    manufacturer_tags: "B",
    job_function: "B",
    summary: "C",
    scope_of_work: "C"
  }, using: {
    tsearch: { prefix: true, any_word: true }
  }

  def pre_negotiated?
    %w(created published quoted).include?(state)
  end

  def is_published?
    state != :created
  end

  def pre_contracted?
    pre_negotiated?
  end

  def work_order
    "WO-"+(id.to_s.rjust(5, '0'))
  end

  enumerize :reporting_frequency, in: [
    :daily,
    :every_other_day,
    :weekly
  ]

  def freelancer
    applicants.with_state(:accepted).first&.freelancer
  end

  def collaborators_for_notifications
    job_collaborators.where(receive_notifications: true).map(&:user)
  end

  def city_state_country
    str = ""
    str += "#{address}, " if address.present?
    str += "#{CS.states(country.to_sym)[state_province.to_sym]}, " if state_province.present?
    str += "#{country.upcase}" if country.present?
    str
  end

  def creation_completed?
    creation_step == "wicked_finish"
  end

  def self.all_job_functions
    I18n.t("enumerize.system_integration_job_functions").merge(I18n.t("enumerize.live_events_staging_and_rental_job_functions"))
  end

  def self.all_job_markets
    I18n.t("enumerize.system_integration_job_markets").merge(I18n.t("enumerize.live_events_staging_and_rental_job_markets"))
  end

  def self.count
    super
  end

  def matches(distance=nil)
    freelancer_profiles = FreelancerProfile.where(disabled: false).where("job_types like ?", "%#{job_type}%")
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
      point = OpenStruct.new(:lat => geocode[:lat], :lng => geocode[:lng])
      if distance.nil?
        distance = 160934
      end
      freelancer_profiles = freelancer_profiles.nearby(geocode[:lat], geocode[:lng], distance).with_distance(point).order("distance")
      Freelancer.where(id: freelancer_profiles.map(&:freelancer_id))
    else
      Freelancer.none
    end
  end

  private

  def scope_or_file
    if scope_of_work.blank? and scope_file_url.nil?
      errors.add(:scope_of_work, "Either a scope of work or a scope file attachment is required")
    end
  end

  def reject_attachments(attrs)
    exists = attrs["id"].present?
    empty = attrs["file"].blank? && attrs["title"].blank?
    attrs.merge!({ _destroy: 1 }) if exists && empty
    !exists and empty
  end

  def check_if_should_do_geocode
    return unless saved_changes.include?("address") || (!address.nil? && lat.nil?)
    do_geocode
    update_columns(lat: lat, lng: lng)
  end

  def accept_applicant
    applicants.where(id: accepted_applicant_id).first&.update_attribute(:state, "accepted")
    applicants.where.not(id: accepted_applicant_id, state: "declined").each do |applicant|
      applicant.update_attribute(:state, "declined")
      Notification.create(title: self.title, body: "Your application was declined", authorable: company, receivable: applicant.freelancer, url: Rails.application.routes.url_helpers.freelancer_job_url(self))
      FreelancerMailer.notice_received_declined_quote(applicant.freelancer, company, self).deliver_later
    end
  end

  def validate_sales_tax
    if send_contract == "true"
      errors.add(:applicable_sales_tax, 'You should set the applicable sales tax!') if applicable_sales_tax.nil?
    end
  end
end
