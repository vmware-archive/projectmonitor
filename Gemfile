source 'https://rubygems.org'

gem "acts-as-taggable-on", :github => "mbleigh/acts-as-taggable-on"
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
gem "sass"
gem "haml"
gem "jquery-rails", '2.0.2'
gem "mime-types"
gem "nokogiri"
gem "omniauth"
gem "omniauth-google-oauth2"
gem "pivotal-tracker", '0.5.8'
gem "rails"
gem "rake"
gem "xpath"
gem 'whenever', :require => false
gem 'rails-backbone', "0.7.2"
gem 'coffee-filter'
gem 'eco'
gem 'pg'

group :production do
  gem "therubyracer"
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
  gem "vcr", "2.2.4"
  gem "fakeweb"
end

# NOTE: anything that will not work in travis should be here
group :development do
  gem "awesome_print"
  gem "heroku_san"
  gem "debugger"
  gem "pry-rails"
  gem 'guard-coffeescript'
end

group :test, :development do
  gem "launchy"
  gem "jshint_on_rails"
  gem "rspec", "2.10.0"
  gem "rspec-rails", "2.10.1"
  gem "shoulda-matchers"
  gem "capybara"
  gem "jasmine"
  # NOTE: selenium-webdriver >= 2.25.0 is needed for the latest Firefox
  gem "selenium-webdriver", ">= 2.25.0"
  gem "factory_girl_rails"
  gem "ffaker"
  gem 'rb-fsevent', '~> 0.9.1'
  gem 'guard-coffeescript'
  gem 'database_cleaner'
  gem "capybara-webkit"
  gem "pry"
  gem "pry-nav"
  gem 'vagrant'
end

