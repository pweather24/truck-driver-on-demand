# == Schema Information
#
# Table name: featured_projects
#
#  id         :integer          not null, primary key
#  company_id :integer
#  name       :string
#  file       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  file_data  :string
#

FactoryGirl.define do
  factory :featured_project do
    
  end
end
