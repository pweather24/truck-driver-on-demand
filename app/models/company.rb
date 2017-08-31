# == Schema Information
#
# Table name: companies
#
#  id                :integer          not null, primary key
#  token             :string
#  email             :citext           not null
#  name              :string           not null
#  contact_name      :string           not null
#  currency          :string           default("CAD"), not null
#  address           :string
#  formatted_address :string
#  area              :string
#  lat               :decimal(9, 6)
#  lng               :decimal(9, 6)
#  hq_country        :string
#  description       :string
#  avatar_data       :text
#  disabled          :boolean          default(FALSE), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Company < ApplicationRecord
  extend Enumerize
  include PgSearch
  include Loginable
  include Geocodable
  include Disableable
  include AvatarUploader[:avatar]
  include ProfileHeaderUploader[:profile_header]

  has_many :identities, as: :loginable, dependent: :destroy
  has_many :projects, -> { order(updated_at: :desc) }, dependent: :destroy
  has_many :jobs, dependent: :destroy
  has_many :applicants, dependent: :destroy
  has_many :quotes, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :messages, -> { order(created_at: :desc) }, as: :authorable
  has_many :freelancer_reviews, dependent: :nullify
  has_many :company_reviews, dependent: :destroy
  has_many :favourites
  has_many :favourite_freelancers, through: :favourites, source: :freelancer

  enumerize :currency, in: [ "CAD", "USD" ]
  enumerize :contract_preference, in: [:prefer_fixed, :prefer_hourly]

  # after_validation :queue_geocode

  def freelancers
    Freelancer.
      joins(applicants: :job).
      where(jobs: { company_id: id }).
      where(applicants: { state: :accepted }).
      order(:name)
  end

  audited

  pg_search_scope :search, against: {
    name: "A",
    email: "A",
    contact_name: "B",
    area: "B",
    formatted_address: "C",
    description: "C"
  }, using: {
    tsearch: { prefix: true }
  }

  # We want to populate both name and contact_name on sign up
  before_validation :set_contact_name, on: :create
  def set_contact_name
    self.contact_name = name unless contact_name
  end

  def rating
    if company_reviews.count > 0
      company_reviews.average("(#{CompanyReview::RATING_ATTRS.map(&:to_s).join('+')}) / #{CompanyReview::RATING_ATTRS.length}").round
    else
      return nil
    end
  end

  # This SQL needs to stay exactly in sync with it's related index (index_on_companies_location)
  # otherwise the index won't be used. (don't even add whitespace!)
  # https://github.com/pairshaped/postgis-on-rails-example
  # scope :near, -> (lat, lng, distance_in_meters = 2000) {
  #   where(%{
  #     ST_DWithin(
  #       ST_GeographyFromText(
  #         'SRID=4326;POINT(' || companies.lng || ' ' || companies.lat || ')'
  #       ),
  #       ST_GeographyFromText('SRID=4326;POINT(%f %f)'),
  #       %d
  #     )
  #   } % [lng, lat, distance_in_meters])
  # }
end
