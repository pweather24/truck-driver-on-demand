# frozen_string_literal: true

# == Schema Information
#
# Table name: attachments
#
#  id         :bigint           not null, primary key
#  file_data  :string
#  job_id     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  title      :string
#

FactoryBot.define do
  factory :attachment do
  end
end
