source :rubygems

gem "acts_as_taggable_on_steroids", :git => "https://github.com/jviney/acts_as_taggable_on_steroids.git"
gem "airbrake"
gem "bourbon"
gem "choices"
gem "daemons"
gem "delayed_job"
gem "delayed_job_active_record"
gem "devise"
gem "devise-encryptable"
# NOTE: Newer versions of draper are currently incompatible with this codebase
gem "draper", "< 0.13"
gem "dynamic_form"
gem "fastthread"
gem "foreman"
gem "haml"
gem "httpauth"
gem "jquery-rails"
gem "mime-types"
gem "nokogiri"
gem "omniauth"
gem "omniauth-google-oauth2"
gem "pivotal-tracker"
gem "rails"
gem "rake"
gem "xpath"
gem 'whenever', :require => false
gem 'rails-backbone'
gem 'coffee-filter'

group :production do
  gem "therubyracer"
end

# group :postgres do
  gem "pg"
# end

group :mysql do
  gem "mysql2"
end

group :thin do
  gem "thin"
end

group :assets do
  gem "compass-rails"
  gem "sass-rails"
  gem "uglifier"
end

group :test do
  gem "headless"
  gem "vcr"
  gem "fakeweb"
end

group :test, :development do
  gem "launchy"
  gem "heroku_san"
  gem "awesome_print"
  gem "jshint_on_rails"
  # NOTE: rake jasmine:ci is not compatible with newer versions of rspec, until
  # this: https://github.com/pivotal/jasmine-gem/issues/94 is resolved lock
  # down rspec
  gem "rspec", "< 2.11"
  gem "rspec-rails"
  gem "shoulda-matchers"
  gem "capybara"
  gem "jasmine"
  # NOTE: selenium-webdriver >= 2.25.0 is needed for the latest Firefox
  gem "selenium-webdriver", ">= 2.25.0"
  gem "factory_girl_rails"
  gem "ffaker"
  gem "debugger"
  gem "pry"
  gem 'guard-coffeescript'
  gem 'rb-fsevent', '~> 0.9.1'
end
