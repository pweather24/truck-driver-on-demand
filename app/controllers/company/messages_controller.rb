# frozen_string_literal: true

class Company::MessagesController < Company::BaseController

  before_action :authorize_company
  before_action :set_driver

  def index
    set_collection
    if params[:job_id] == "profile"
      @job_or_profile = "profile"
    elsif params[:job_id].present? && @messages.select { |msg| msg.job_id == params[:job_id].to_i }.count.zero?
      @job_or_profile = Job.find(params[:job_id])
    end
    current_company.notifications.where(authorable: @driver).each(&:mark_as_read)
  end

  private

  def authorize_company
    authorize current_company
  end

  def set_driver
    @driver = Driver.find(params[:driver_id])
  end

  def set_collection
    @messages = current_company.messages_for_driver(@driver)
  end

end
