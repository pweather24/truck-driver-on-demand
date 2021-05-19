# frozen_string_literal: true

source "https://rubygems.org"

ruby "2.6.0"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 5.1.0.rc2"
# Use postgres as the database for Active Record
gem "pg", "~> 0.18"
# Use Puma as the app server
gem "puma", "~> 4.3"
# Use SCSS for stylesheets
gem "sass-rails", github: "rails/sass-rails"
# Use Bootstrap SASS
gem "bootstrap-sass"
# Use FontAwesome
gem "font-awesome-rails", "~> 4.7.0"
# Use Uglifier as compressor for JavaScript assets
gem "uglifier", "~> 3.2.0"
# Use JQuery
gem "jquery-rails", "~> 4.3.1"
# Use JQuery Datatables
gem "jquery-datatables"
# Use Chartkick
gem "chartkick", "~> 3.2.0"
# Use CoffeeScript for .coffee assets and views
gem "coffee-rails", "~> 4.2"
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem "turbolinks", "~> 5"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.5"
# Use PG Search
gem "pg_search", "~> 2.0.1"
# Use Enumerize
gem "enumerize", "~> 2.1.2"
# Use audited
gem "audited", "~> 4.5.0"
# Use easy_postgis
gem "easy_postgis"
# Use activejob-perform_later
gem "activejob-perform_later", "~> 1.0.2"
# Use Devise for authentication
gem "devise", "~> 4.7.1"
# Use Devise Invitable
gem "devise_invitable"
# Use Pundit for authorization
gem "pundit"
# Use SLIM
gem "slim-rails", "~> 3.1.2"
# Use Simple Form
gem "simple_form", "~> 5.0.0"
# Use Cocoon
gem "cocoon", "~> 1.2.10"
# Use Avatax
gem "avatax"
# Use Taxjar-Ruby
gem "taxjar-ruby", require: "taxjar"
# Use Kaminari
gem "kaminari", "~> 1.0.1"
# Use TheRubyRacer
gem "therubyracer", platforms: :ruby
# Use Coderay
gem "coderay", "~> 1.1.1"
# Use RedCarpet
gem "redcarpet", "~> 3.4.0"
# Use Wickerd PDF
gem "wicked_pdf", "~> 1.1.0"
# Use wkhtmltopdf-binary
gem "wkhtmltopdf-binary", "~> 0.12.3.1"
# Use Wiked
gem "wicked"
# Use hashids
gem "hashids"
# Use Carrierwave
gem "carrierwave", "~> 1.0.0"
# Use Shrine
gem "shrine", "~> 2.6.1"
# Use Image Processing
gem "image_processing", "~> 0.4.1"
# Use FastImage
gem "fastimage", "~> 2.1.0" # TODO: Do we use this gem?
# Use MiniMagick
gem "mini_magick", "~> 4.9.4"
# Use whenever
gem "whenever", require: false
# Use SMTP
gem "smtpapi"
# Use Listen
gem "listen"
# Use Rack Mini Profiler
gem "rack-mini-profiler", "~> 0.10.2"
# Use Flamegraph
gem "flamegraph", "~> 0.9.5"
# Use Stackprof
gem "stackprof", "~> 0.2.10"
# Use Bullet
gem "bullet", "~> 5.5.1"
# Use CityState
gem "city-state"
# Use TRIX
gem "trix"
# Use Truncato
gem "truncato"
# Use twilio for SMS
gem "twilio-ruby", "~> 5.29.0"
# Use rack-cors for CORS
gem "rack-cors"
# Admin
gem 'activeadmin'
# State Machine
gem 'aasm'

group :development, :test do
  gem "dotenv-rails"
  gem "factory_bot_rails"
  gem "faker"
  gem "pry-byebug"
  gem "rspec-rails"
end

group :development do
  gem "annotate", git: "https://github.com/ctran/annotate_models.git"
  gem "better_errors"
  gem "binding_of_caller"
  gem "capistrano", "~> 3.8.1"
  gem "capistrano-passenger"
  gem "capistrano-rails", "~> 1.2.3"
  gem "rails-erd"
  gem "rubocop"
end

group :test do
  gem "capybara"
  gem "cucumber"
  gem "cucumber-rails", require: false
  gem "database_cleaner"
  gem "launchy"
  gem "rails-controller-testing"
  gem "rspec_junit_formatter"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
  gem "simplecov"
  gem "timecop"
  gem "vcr"
  gem "webmock"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
