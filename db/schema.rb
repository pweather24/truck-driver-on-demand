# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20191230153401) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"
  enable_extension "citext"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "applicants", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.bigint "job_id", null: false
    t.bigint "driver_id", null: false
    t.string "state", default: "quoting", null: false
    t.integer "quotes_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "messages_count", default: 0, null: false
    t.index ["company_id"], name: "index_applicants_on_company_id"
    t.index ["driver_id"], name: "index_applicants_on_driver_id"
    t.index ["job_id"], name: "index_applicants_on_job_id"
  end

  create_table "attachments", force: :cascade do |t|
    t.string "file_data"
    t.integer "job_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
  end

  create_table "audits", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.jsonb "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_id", "associated_type"], name: "associated_index"
    t.index ["auditable_id", "auditable_type"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "certifications", force: :cascade do |t|
    t.integer "driver_id"
    t.text "certificate"
    t.text "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "thumbnail"
    t.text "certificate_data"
    t.string "cert_type"
  end

  create_table "change_orders", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.bigint "job_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.text "body", null: false
    t.text "attachment_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_change_orders_on_company_id"
    t.index ["job_id"], name: "index_change_orders_on_job_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "token"
    t.string "name"
    t.string "address"
    t.string "formatted_address"
    t.string "area"
    t.decimal "lat", precision: 9, scale: 6
    t.decimal "lng", precision: 9, scale: 6
    t.string "hq_country"
    t.string "description"
    t.text "avatar_data"
    t.boolean "disabled", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "messages_count", default: 0, null: false
    t.integer "company_reviews_count", default: 0, null: false
    t.text "profile_header_data"
    t.string "contract_preference", default: "no_preference"
    t.citext "job_markets"
    t.citext "technical_skill_tags"
    t.integer "profile_views", default: 0, null: false
    t.string "website"
    t.string "phone_number"
    t.integer "number_of_offices", default: 0
    t.string "number_of_employees"
    t.integer "established_in"
    t.string "header_color", default: "FF6C38"
    t.string "country"
    t.string "header_source", default: "default"
    t.string "sales_tax_number"
    t.string "line2"
    t.string "city"
    t.string "state"
    t.string "postal_code"
    t.citext "job_types"
    t.citext "manufacturer_tags"
    t.string "registration_step"
    t.citext "saved_drivers_ids"
    t.index "st_geographyfromtext((((('SRID=4326;POINT('::text || lng) || ' '::text) || lat) || ')'::text))", name: "index_on_companies_loc", using: :gist
    t.index ["disabled"], name: "index_companies_on_disabled"
    t.index ["name"], name: "index_companies_on_name"
  end

  create_table "company_favourites", force: :cascade do |t|
    t.integer "driver_id"
    t.integer "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "company_installs", force: :cascade do |t|
    t.integer "company_id"
    t.integer "year"
    t.integer "installs"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "company_reviews", force: :cascade do |t|
    t.bigint "company_id"
    t.bigint "driver_id"
    t.bigint "job_id"
    t.integer "quality_of_information_provided", null: false
    t.integer "communication", null: false
    t.integer "materials_available_onsite", null: false
    t.integer "promptness_of_payment", null: false
    t.integer "overall_experience", null: false
    t.text "comments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_company_reviews_on_company_id"
    t.index ["driver_id"], name: "index_company_reviews_on_driver_id"
    t.index ["job_id"], name: "index_company_reviews_on_job_id"
  end

  create_table "currency_rates", force: :cascade do |t|
    t.string "currency"
    t.string "country"
    t.decimal "rate", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "driver_affiliations", force: :cascade do |t|
    t.string "name"
    t.string "image"
    t.integer "driver_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "image_data"
  end

  create_table "driver_clearances", force: :cascade do |t|
    t.text "description"
    t.string "image"
    t.text "image_data"
    t.integer "driver_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "driver_insurances", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "driver_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image"
    t.text "image_data"
  end

  create_table "driver_portfolios", force: :cascade do |t|
    t.text "name"
    t.string "image"
    t.text "image_data"
    t.integer "driver_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "driver_profiles", force: :cascade do |t|
    t.string "token"
    t.text "avatar_data"
    t.string "tagline"
    t.text "bio"
    t.integer "profile_views", default: 0, null: false
    t.boolean "available", default: true, null: false
    t.boolean "disabled", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "driver_reviews_count", default: 0, null: false
    t.boolean "verified", default: false
    t.string "driver_type"
    t.string "postal_code"
    t.string "service_areas"
    t.string "city"
    t.integer "profile_score", limit: 2
    t.string "registration_step"
    t.integer "driver_id"
    t.boolean "requested_verification", default: false
    t.string "province"
    t.citext "transmission_and_speed"
    t.citext "freight_type"
    t.citext "other_skills"
    t.citext "vehicle_type"
    t.citext "truck_type"
    t.citext "trailer_type"
    t.string "address_line1"
    t.string "address_line2"
    t.text "background_check_data"
    t.boolean "completed_profile", default: false
    t.string "years_of_experience"
    t.string "business_name"
    t.string "hst_number"
    t.text "cvor_abstract_data"
    t.boolean "cvor_abstract_uploaded", default: false
    t.text "driver_abstract_data"
    t.boolean "driver_abstract_uploaded", default: false
    t.string "driving_school"
    t.boolean "drivers_license_uploaded", default: false
    t.text "resume_data"
    t.boolean "resume_uploaded", default: false
    t.boolean "accept_wsib", default: false
    t.boolean "accept_health_and_safety", default: false
    t.boolean "accept_excess_hours", default: false
    t.boolean "accept_terms_and_conditions", default: false
    t.boolean "previously_registered_with_tpi"
    t.index ["available"], name: "index_driver_profiles_on_available"
    t.index ["disabled"], name: "index_driver_profiles_on_disabled"
    t.index ["driver_id"], name: "index_driver_profiles_on_driver_id"
  end

  create_table "driver_reviews", force: :cascade do |t|
    t.bigint "driver_id"
    t.bigint "company_id"
    t.bigint "job_id"
    t.integer "availability", null: false
    t.integer "communication", null: false
    t.integer "adherence_to_schedule", null: false
    t.integer "skill_and_quality_of_work", null: false
    t.integer "overall_experience", null: false
    t.text "comments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_driver_reviews_on_company_id"
    t.index ["driver_id"], name: "index_driver_reviews_on_driver_id"
    t.index ["job_id"], name: "index_driver_reviews_on_job_id"
  end

  create_table "driver_test_results", force: :cascade do |t|
    t.bigint "driver_test_id", null: false
    t.bigint "driver_id", null: false
    t.jsonb "answers"
    t.float "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["driver_id"], name: "index_driver_test_results_on_driver_id"
    t.index ["driver_test_id"], name: "index_driver_test_results_on_driver_test_id"
  end

  create_table "driver_tests", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "drivers_licenses", force: :cascade do |t|
    t.bigint "driver_profile_id", null: false
    t.text "license_data"
    t.string "license_number"
    t.date "exp_date"
    t.string "license_class"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["driver_profile_id"], name: "index_drivers_licenses_on_driver_profile_id"
  end

  create_table "favourites", force: :cascade do |t|
    t.integer "driver_id"
    t.integer "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "featured_projects", force: :cascade do |t|
    t.integer "company_id"
    t.string "name"
    t.string "file"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "file_data"
  end

  create_table "friend_invites", force: :cascade do |t|
    t.citext "email", null: false
    t.string "name", null: false
    t.bigint "driver_id", null: false
    t.boolean "accepted", default: false
    t.index ["driver_id"], name: "index_friend_invites_on_driver_id"
  end

  create_table "identities", force: :cascade do |t|
    t.string "loginable_type", null: false
    t.bigint "loginable_id", null: false
    t.string "provider", null: false
    t.string "uid", null: false
    t.datetime "last_sign_in_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["loginable_type", "loginable_id"], name: "index_identities_on_loginable_type_and_loginable_id"
    t.index ["loginable_type", "provider", "uid"], name: "index_identities_on_loginable_type_and_provider_and_uid", unique: true
  end

  create_table "job_collaborators", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "user_id", null: false
    t.boolean "receive_notifications", default: true
    t.index ["job_id"], name: "index_job_collaborators_on_job_id"
    t.index ["user_id"], name: "index_job_collaborators_on_user_id"
  end

  create_table "job_favourites", force: :cascade do |t|
    t.integer "driver_id"
    t.integer "job_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "job_invites", force: :cascade do |t|
    t.integer "job_id"
    t.integer "driver_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "jobs", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "title"
    t.string "state", default: "created", null: false
    t.text "summary"
    t.text "technical_skill_tags"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "address"
    t.decimal "lat", precision: 9, scale: 6
    t.decimal "lng", precision: 9, scale: 6
    t.string "formatted_address"
    t.string "country"
    t.citext "job_markets"
    t.citext "manufacturer_tags"
    t.string "state_province"
    t.index ["company_id"], name: "index_jobs_on_company_id"
  end

  create_table "messages", force: :cascade do |t|
    t.string "authorable_type", null: false
    t.bigint "authorable_id", null: false
    t.string "receivable_type", null: false
    t.bigint "receivable_id", null: false
    t.text "body"
    t.text "attachment_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "checkin", default: false
    t.boolean "send_contract", default: false
    t.boolean "unread", default: true
    t.bigint "job_id"
    t.index ["authorable_type", "authorable_id"], name: "index_messages_on_authorable_type_and_authorable_id"
    t.index ["job_id"], name: "index_messages_on_job_id"
    t.index ["receivable_type", "receivable_id"], name: "index_messages_on_receivable_type_and_receivable_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "authorable_type", null: false
    t.bigint "authorable_id", null: false
    t.string "receivable_type", null: false
    t.bigint "receivable_id", null: false
    t.text "body"
    t.text "title"
    t.datetime "read_at"
    t.text "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["authorable_type", "authorable_id"], name: "index_notifications_on_authorable_type_and_authorable_id"
    t.index ["receivable_type", "receivable_id"], name: "index_notifications_on_receivable_type_and_receivable_id"
  end

  create_table "pages", force: :cascade do |t|
    t.string "slug", null: false
    t.string "title", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_pages_on_slug"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "first_name"
    t.string "last_name"
    t.string "type"
    t.integer "messages_count", default: 0, null: false
    t.bigint "company_id"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.string "phone_number"
    t.string "role"
    t.boolean "enabled", default: true
    t.string "login_code"
    t.string "city"
    t.index ["company_id"], name: "index_users_on_company_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by_type_and_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "applicants", "companies"
  add_foreign_key "applicants", "jobs"
  add_foreign_key "applicants", "users", column: "driver_id"
  add_foreign_key "change_orders", "companies"
  add_foreign_key "change_orders", "jobs"
  add_foreign_key "company_reviews", "companies"
  add_foreign_key "company_reviews", "jobs"
  add_foreign_key "company_reviews", "users", column: "driver_id"
  add_foreign_key "driver_reviews", "companies"
  add_foreign_key "driver_reviews", "jobs"
  add_foreign_key "driver_reviews", "users", column: "driver_id"
  add_foreign_key "driver_test_results", "driver_tests"
  add_foreign_key "driver_test_results", "users", column: "driver_id"
  add_foreign_key "drivers_licenses", "driver_profiles"
  add_foreign_key "job_collaborators", "jobs"
  add_foreign_key "job_collaborators", "users"
  add_foreign_key "jobs", "companies"
  add_foreign_key "messages", "jobs"
  add_foreign_key "test_questions", "driver_tests"
end
