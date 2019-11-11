# frozen_string_literal: true

# == Schema Information
#
# Table name: company_favourites
#
#  id         :bigint           not null, primary key
#  driver_id  :integer
#  company_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CompanyFavourite < ApplicationRecord

  belongs_to :driver, class_name: "User", foreign_key: "driver_id"
  belongs_to :company

end
