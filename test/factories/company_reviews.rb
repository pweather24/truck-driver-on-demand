# == Schema Information
#
# Table name: company_reviews
#
#  id                              :integer          not null, primary key
#  company_id                      :integer
#  freelancer_id                   :integer
#  job_id                          :integer
#  quality_of_information_provided :integer          not null
#  communication                   :integer          not null
#  materials_available_onsite      :integer          not null
#  promptness_of_payment           :integer          not null
#  overall_experience              :integer          not null
#  comments                        :text
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#

FactoryGirl.define do
  factory :company_review do
    company nil
    freelancer nil
    job nil
    quality_of_information_provided "MyString"
    promptness_of_payment "MyString"
    material_available_on_site "MyString"
    communication "MyString"
    comments "MyText"
  end
end
