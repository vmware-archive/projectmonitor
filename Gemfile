source :rubygems
gem "bundler"

gem "rails", "3.0.3"
gem "rake"
gem "gem_plugin"
gem "mime-types"
gem "fastthread"
gem "nokogiri"
gem "httpauth"
gem "acts_as_taggable_on_steroids"
gem "ruby-openid"
gem "ruby-openid-apps-discovery"
gem "delayed_job"
gem "dynamic_form"


group :postgres do
  gem "pg"
end

group :mysql do
  gem "mysql2"   ### assume in system gems
end

group :development do
  gem "heroku"
  gem "sqlite3-ruby", "1.3.1"
  gem 'ruby-debug-base19', :platforms => :mri_19
  gem 'ruby-debug-base', :platforms => :mri_18
  gem "ruby-debug-ide"
  gem "capistrano"
  gem "capistrano-ext"
  gem "soloist"
  gem "rvm"
  gem "fog"
end

group :test do
  gem "jasmine", "1.0.1.1"
  gem "headless", "0.1.0"
end

group :test, :development do
  gem "rspec-rails", "2.2.0"
end
