# frozen_string_literal: true

# == Schema Information
#
# Table name: freelancer_profiles
#
#  id                       :integer          not null, primary key
#  token                    :string
#  avatar_data              :text
#  address                  :string
#  formatted_address        :string
#  area                     :string
#  lat                      :decimal(9, 6)
#  lng                      :decimal(9, 6)
#  tagline                  :string
#  bio                      :text
#  job_markets              :citext
#  years_of_experience      :integer          default(0), not null
#  profile_views            :integer          default(0), not null
#  available                :boolean          default(TRUE), not null
#  disabled                 :boolean          default(TRUE), not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  freelancer_reviews_count :integer          default(0), not null
#  technical_skill_tags     :citext
#  verified                 :boolean          default(FALSE)
#  country                  :string
#  freelancer_team_size     :string
#  freelancer_type          :string
#  line2                    :string
#  state                    :string
#  postal_code              :string
#  service_areas            :string
#  city                     :string
#  profile_score            :integer
#  valid_driver             :boolean
#  own_tools                :boolean
#  company_name             :string
#  job_functions            :citext
#  manufacturer_tags        :citext
#  registration_step        :string
#  province                 :string
#  freelancer_id            :integer
#  requested_verification   :boolean          default(FALSE)
#  pay_unit_time_preference :string
#  pay_rate                 :float
#
# Indexes
#
#  index_freelancer_profiles_on_area                  (area)
#  index_freelancer_profiles_on_available             (available)
#  index_freelancer_profiles_on_disabled              (disabled)
#  index_freelancer_profiles_on_freelancer_id         (freelancer_id)
#  index_freelancer_profiles_on_job_functions         (job_functions)
#  index_freelancer_profiles_on_job_markets           (job_markets)
#  index_freelancer_profiles_on_manufacturer_tags     (manufacturer_tags)
#  index_freelancer_profiles_on_technical_skill_tags  (technical_skill_tags)
# rubocop:disable Metrics/LineLength
#  index_on_freelancer_profiles_loc                   (st_geographyfromtext((((('SRID=4326;POINT('::text || lng) || ' '::text) || lat) || ')'::text)))
#  index_on_freelancers_loc                           (st_geographyfromtext((((('SRID=4326;POINT('::text || lng) || ' '::text) || lat) || ')'::text)))
# rubocop:enable Metrics/LineLength
#

require "rails_helper"

describe FreelancerProfile, type: :model do
  describe "hooks" do
    describe "set_default_step" do
      let(:freelancer_profile) { create(:freelancer_profile) }
      it "sets default step to personal" do
        expect(freelancer_profile.registration_step).to eq("personal")
      end
    end

    describe "after update" do
      let(:freelancer_profile) { create(:freelancer_profile, freelancer: create(:freelancer)) }
      let(:params) { { registration_step: "wicked_finish" } }

      context "when registration is completed" do
        it "calls send_welcome_email" do
          expect(freelancer_profile).to receive(:send_welcome_email)
          freelancer_profile.update(params)
        end
      end

      context "when the freelancer is not confirmed" do
        it "sends the confirmation mail" do
          expect { freelancer_profile.update(params) }.to change(ActionMailer::Base.deliveries, :count).by(1)
        end
      end

      context "when the freelancer is confirmed" do
        it "does not send the confirmation mail" do
          freelancer_profile.freelancer.confirm
          expect { freelancer_profile.update(params) }.to change(ActionMailer::Base.deliveries, :count).by(0)
        end
      end
    end
  end
end
