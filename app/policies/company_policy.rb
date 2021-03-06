# frozen_string_literal: true

class CompanyPolicy < ApplicationPolicy

  def index?
    company_user?
  end

  def show?
    (company_user? && company_owner?) || driver? || admin?
  end

  def new?
    (company_user? && company_owner?) || admin?
  end

  def thanks?
    (company_user? && company_owner?) || admin?
  end

  def create?
    (company_user? && company_owner?) || admin?
  end

  def edit?
    (company_user? && company_owner?) || admin?
  end

  def update?
    (company_user? && company_owner?) || admin?
  end

  def destroy?
    admin?
  end

  def webhook?
    company_user? && company_owner?
  end

  def jobs?
    admin?
  end

  def enable?
    admin?
  end

  def disable?
    admin?
  end

  def add_favourites?
    company_user?
  end

  def invoices?
    company_user? && company_owner?
  end

  def reset_company?
    company_user? && company_owner?
  end

  def update_card_info?
    company_user? && company_owner?
  end

  def save_driver?
    company_user? && company_owner?
  end

  def delete_driver?
    company_user? && company_owner?
  end

  private

  def company_owner?
    return false unless company_user?

    record.id == user.company.id
  end

end
