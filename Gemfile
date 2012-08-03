source :rubygems

gem "rails"
gem "rake"

gem "mime-types"
gem "fastthread"
gem "nokogiri"
gem "httpauth"
gem "acts_as_taggable_on_steroids", :git => "https://github.com/jviney/acts_as_taggable_on_steroids.git"
gem "ruby-openid"
gem "ruby-openid-apps-discovery"
gem "delayed_job"
gem "dynamic_form"
gem "delayed_job_active_record"
gem "daemons"
gem "jquery-rails"
gem "foreman"
gem "bourbon"
# NOTE: Newer versions of draper are currently incompatible with this codebase
gem "draper", "< 0.13"
gem "awesome_print"
gem "pivotal-tracker"
gem "heroku_san"
gem "airbrake"
gem "haml"

group :production do
  gem "therubyracer"
end

group :postgres do
  gem "pg"
end

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

group :development do
  gem "heroku"
  gem "capistrano"
  gem "capistrano-ext"
  gem "soloist"
  gem "pivotal_git_scripts"
  gem "rails-erd"
end

group :test do
  gem "headless"
  gem "vcr"
  gem "fakeweb"
end

group :test, :development do
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
end
