# frozen_string_literal: true

class AddStripeFieldsToCompanies < ActiveRecord::Migration[5.1]
  def change
    add_column :companies, :stripe_customer_id, :string, limit: 40
    add_column :companies, :stripe_subscription_id, :string, limit: 30
    add_column :companies, :stripe_plan_id, :string, limit: 20
    add_column :companies, :subscription_cycle, :string, limit: 10
    add_column :companies, :is_subscription_cancelled, :boolean, default: false
    add_column :companies, :subscription_status, :string, limit: 10
    add_column :companies, :billing_period_ends_at, :datetime
    add_column :companies, :last_4_digits, :string, limit: 4
    add_column :companies, :card_brand, :string, limit: 20
    add_column :companies, :exp_month, :string, limit: 2
    add_column :companies, :exp_year, :string, limit: 4
  end
end
