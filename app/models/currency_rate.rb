# frozen_string_literal: true

# == Schema Information
#
# Table name: currency_rates
#
#  id         :bigint           not null, primary key
#  currency   :string
#  country    :string
#  rate       :decimal(10, 2)   not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CurrencyRate < ApplicationRecord
end
