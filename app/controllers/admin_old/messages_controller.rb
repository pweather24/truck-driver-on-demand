# frozen_string_literal: true

class Admin::MessagesController < Admin::BaseController

  before_action :authorize_user
  before_action :set_driver
  before_action :set_company

  def index
    set_collection
  end

  private

  def authorize_user
    authorize current_user
  end

  def set_driver
    @driver = Driver.find(params[:driver_id])
  end

  def set_company
    @company = Company.find(params[:company_id])
  end

  def set_collection
    @messages = @company.messages_for_driver(@driver)
  end

end
