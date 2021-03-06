# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  first_name             :string
#  last_name              :string
#  type                   :string
#  messages_count         :integer          default(0), not null
#  company_id             :bigint
#  invitation_token       :string
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invitation_limit       :integer
#  invited_by_type        :string
#  invited_by_id          :bigint
#  invitations_count      :integer          default(0)
#  phone_number           :string
#  role                   :string
#  enabled                :boolean          default(TRUE)
#  login_code             :string
#  city                   :string
#

class CompanyUser < User

  audited

  belongs_to :company
  has_many :job_collaborators, foreign_key: "user_id", dependent: :destroy
  has_many :jobs, foreign_key: "creator_id"

  before_validation :initialize_company
  before_create :set_role

  attr_accessor :accept_terms_of_service, :accept_privacy_policy, :accept_code_of_conduct,
                :enforce_profile_edit, :user_type

  validates_acceptance_of :accept_terms_of_service
  validates_acceptance_of :accept_privacy_policy
  validates_acceptance_of :accept_code_of_conduct

  delegate :registration_completed?, to: :company

  def available_jobs
    if role == "Owner"
      company.jobs
    else
      company.jobs.where(id: job_collaborators.map(&:job_id))
    end
  end

  def notifications
    Notification.where(receivable_id: id, receivable_type: "User")
                .or(Notification.where(receivable_id: company.id, receivable_type: "Company"))
  end

  protected

  def confirmation_required?
    registration_completed?
  end

  private

  def initialize_company
    self.company ||= build_company
  end

  def send_confirmation_notification?
    false
  end

  def set_role
    self.role = "Owner" if role.blank?
  end

end
