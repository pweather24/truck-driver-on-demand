# frozen_string_literal: true

class DriverPolicy < ApplicationPolicy

  def index?
    driver?
  end

  def identity?
    driver? && driver_owner?
  end

  def connect?
    driver? && driver_owner?
  end

  def prepare_info?
    driver? && driver_owner?
  end

  def bank_account?
    driver? && driver_owner?
  end

  def add_bank_account?
    driver? && driver_owner?
  end

  def show?
    driver? || company_user? || admin?
  end

  def company_index?
    company_user?
  end

  def hired?
    company_user?
  end

  def favourites?
    (driver? && driver_owner?) || company_user?
  end

  def edit?
    (driver? && driver_owner?) || admin?
  end

  def update?
    (driver? && driver_owner?) || admin?
  end

  def destroy?
    admin?
  end

  def enable?
    admin?
  end

  def disable?
    admin?
  end

  def add_favourites?
    driver? && driver_owner?
  end

  def my_jobs?
    driver? && driver_owner?
  end

  def my_applications?
    driver? && driver_owner?
  end

  def job_matches?
    driver? && driver_owner?
  end

  def complete_profile?
    driver?
  end

  def complete_profile_update?
    driver?
  end

  def cvor_abstract?
    driver?
  end

  def upload_cvor_abstract?
    driver?
  end

  def driver_abstract?
    driver?
  end

  def upload_driver_abstract?
    driver?
  end

  def drivers_license?
    driver?
  end

  def upload_drivers_license?
    driver?
  end

  def resume?
    driver?
  end

  def upload_resume?
    driver?
  end

  def health_and_safety?
    driver?
  end

  def accept_health_and_safety?
    driver?
  end

  def wsib?
    driver?
  end

  def accept_wsib?
    driver?
  end

  def excess_hours?
    driver?
  end

  def accept_excess_hours?
    driver?
  end

  def terms_and_conditions?
    driver?
  end

  def accept_terms_and_conditions?
    driver?
  end

  def previously_registered?
    driver?
  end

  def previously_registered_answer?
    driver?
  end

  def answer?
    driver?
  end

  private

  def driver_owner?
    return false unless driver?

    record.id == user.id
  end

end
