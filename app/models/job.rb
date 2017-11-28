# == Schema Information
#
# Table name: jobs
#
#  id                        :integer          not null, primary key
#  company_id                :integer          not null
#  project_id                :integer          not null
#  title                     :string           not null
#  state                     :string           default("created"), not null
#  summary                   :text             not null
#  scope_of_work             :text
#  budget                    :decimal(10, 2)   not null
#  job_function              :string           not null
#  starts_on                 :date             not null
#  ends_on                   :date
#  duration                  :integer          not null
#  pay_type                  :string
#  freelancer_type           :string           not null
#  keywords                  :text
#  invite_only               :boolean          default(FALSE), not null
#  scope_is_public           :boolean          default(TRUE), not null
#  budget_is_public          :boolean          default(TRUE), not null
#  working_days              :text             default([]), not null, is an Array
#  working_time              :string
#  contract_price            :decimal(10, 2)
#  payment_schedule          :jsonb            not null
#  reporting_frequency       :string
#  require_photos_on_updates :boolean          default(FALSE), not null
#  require_checkin           :boolean          default(FALSE), not null
#  require_uniform           :boolean          default(FALSE), not null
#  addendums                 :text
#  applicants_count          :integer          default(0), not null
#  messages_count            :integer          default(0), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class Job < ApplicationRecord
  extend Enumerize
  include Geocodable
  include PgSearch
  include EasyPostgis
  include ScopeFileUploader[:scope_file]

  belongs_to :company
  belongs_to :project
  has_many :applicants, -> { includes(:freelancer).order(updated_at: :desc) }, dependent: :destroy
  has_many :quotes, -> { order(created_at: :desc) }, through: :applicants
  has_many :messages, -> { order(created_at: :desc) }, as: :receivable
  has_many :change_orders, -> { order(updated_at: :desc) }, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :attachments, dependent: :destroy
  has_one :freelancer_review, dependent: :nullify
  has_one :company_review, dependent: :nullify
  has_many :job_invites

  accepts_nested_attributes_for :payments, allow_destroy: true, reject_if: :reject_payments
  accepts_nested_attributes_for :attachments, allow_destroy: true, reject_if: :reject_attachments

  schema_validations except: :working_days

  serialize :keywords

  attr_accessor :send_contract

  audited

  enumerize :job_function, in: [
    :av_installation_technician,
    :av_rental_and_staging_technician,
    :av_programmer,
    :general_laborer,
    :camera_operator,
    :projectionist,
    :project_manager,
    :drafter,
    :a1_audio_engineer,
    :a2_audio_assist,
    :l1_lighting_engineer,
    :l2_lighting_assist,
    :me_master_electrician,
    :v1_video_engineer,
    :v2_video_assist
  ]

  enumerize :working_time, in: [
    :standard_workday,
    :evenings,
    :weekend,
    :any_time
  ]

  pg_search_scope :search, against: {
    title: "A",
    keywords: "B",
    summary: "C",
    scope_of_work: "C"
  }, using: {
    tsearch: { prefix: true, any_word: true }
  }

  enumerize :pay_type, in: [ :fixed, :hourly, :daily ]

  enumerize :freelancer_type, in: [ :independent, :team ]

  enumerize :state, in: [
    :created,
    :published,
    :quoted,
    :negotiated,
    :contracted,
    :completed
  ], predicates: true, scope: true

  # enumerize :currency, in: [
  #   :cad,
  #   :euro,
  #   :ruble,
  #   :rupee,
  #   :usd,
  #   :yen,
  # ]

  validate :validate_number_of_payments

  def validate_number_of_payments
    if send_contract == "true"
      remaining_payments = payments.reject(&:marked_for_destruction?)
      errors.add(:number_of_payments, 'A minimum of 1 payment is required') if remaining_payments.empty?
    end
  end

  validate :validate_payments_total
  def validate_payments_total
    if send_contract == "true"
      total = payments.map(&:amount).inject(0, &:+)
      errors.add(:total_of_payments, 'The total amount of payments doesn\'t match with the quote') if total != quotes.where({state: :accepted}).first.amount
    end
  end

  validate :validate_sales_tax
  def validate_sales_tax
    if send_contract == "true"
      errors.add(:applicable_sales_tax, 'You should set the applicable sales tax!') if applicable_sales_tax.nil?
    end
  end

  def pre_negotiated?
    %w(created published quoted).include?(state)
  end

  def pre_contracted?
    pre_negotiated? || negotiated?
  end

  def accepted_quote
    if quotes.where({state: :accepted}).count > 0
      return quotes.where({state: :accepted}).first
    else
      return nil
    end
  end

  def work_order
    "WO-"+(id.to_s.rjust(5, '0'))
  end

  enumerize :reporting_frequency, in: [
    :daily,
    :every_other_day,
    :weekly
  ]

  enumerize :country, in: [
    :at, :au, :be, :ca, :ch, :de, :dk, :es, :fi, :fr, :gb, :hk, :ie, :it, :jp, :lu, :nl, :no, :nz, :pt, :se, :sg, :us
  ]

  validates :budget, numericality: true, sane_price: true
  validates :job_function, inclusion: { in: job_function.values }
  validates :duration, numericality: { only_integer: true }
  validates :pay_type, inclusion: { in: pay_type.values }, allow_blank: true
  validates :freelancer_type, inclusion: { in: freelancer_type.values }
  validates_presence_of :currency
  validates_presence_of :country
  validate :scope_or_file
  validates_presence_of :address
  validates_presence_of :keywords

  def freelancer
    applicants.with_state(:accepted).first&.freelancer
  end

  def payments_sum_paid
    payments.
      select { |p| p.paid_on.present? }.
      sum { |p| p.amount || 0 }
  end

  def payments_sum_outstanding
    payments.
      select { |p| p.paid_on.blank? }.
      sum { |p| p.amount || 0 }
  end

  def payments_sum_total
    payments.
      sum { |p| p.amount || 0 }
  end

  def gpayments_sum_paid
    payments_sum_paid * (1 + (applicable_sales_tax / 100))
  end

  def gpayments_sum_outstanding
    payments_sum_outstanding (1 + (applicable_sales_tax / 100))
  end

  def gpayments_sum_total
    payments_sum_total (1 + (applicable_sales_tax / 100))
  end

  private

    def scope_or_file
      if scope_of_work.blank? and scope_file_url.nil?
        errors.add(:scope_of_work, "Either a scope of work or a scope file attachment is required")
      end
    end

    def reject_payments(attrs)
      exists = attrs["id"].present?
      empty = attrs["description"].blank? && attrs["amount"].blank?
      attrs.merge!({ _destroy: 1 }) if exists && empty
      !exists and empty
    end

    def reject_attachments(attrs)
      exists = attrs["id"].present?
      empty = attrs["file"].blank?
      exists
    end

    after_save :check_if_should_do_geocode
    def check_if_should_do_geocode
      if saved_changes.include?("address") or (!address.nil? and lat.nil?)
        do_geocode
        update_columns(lat: lat, lng: lng)
      end
    end

end
