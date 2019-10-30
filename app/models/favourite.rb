# frozen_string_literal: true

# == Schema Information
#
# Table name: favourites
#
#  id            :integer          not null, primary key
#  freelancer_id :integer
#  company_id    :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Favourite < ApplicationRecord

  belongs_to :freelancer
  belongs_to :company

end
