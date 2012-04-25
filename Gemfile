source :rubygems

gem "rails", "~> 3.2.0"
gem "rake", "~> 0.9.2"

gem "gem_plugin", "~> 0.2.0"
gem "mime-types", "~> 1.18"
gem "fastthread", "~> 1.0.7"
gem "nokogiri", "~> 1.5.2"
gem "httpauth", "~> 0.1"
gem "acts_as_taggable_on_steroids", :git => "https://github.com/jviney/acts_as_taggable_on_steroids.git"
gem "ruby-openid", "~> 2.1.8"
gem "ruby-openid-apps-discovery", "~> 1.2.0"
gem "delayed_job", "~> 3.0.1"
gem "dynamic_form", "~> 1.1.4"
gem "aws-sdk", "~> 1.3.6"
gem "delayed_job_active_record", "~> 0.3.2"
gem "daemons", "~> 1.1.8"
gem "jquery-rails", "~> 2.0.1"
gem "foreman", "~> 0.41.0"
gem "bourbon", "~> 2.0.0.rc1"
gem "draper", "~> 0.11.1"
gem "awesome_print"

group :production do
  gem "therubyracer"
end

group :postgres do
  gem "pg", "~> 0.13.2"
end

group :mysql do
  gem "mysql2", "~> 0.3.0"
end

group :thin do
  gem "thin", "~> 1.3.1"
end

group :assets do
  gem "sass-rails", "~> 3.2.3"
  gem "uglifier", "~> 1.0.3"
end

group :development do
  gem "heroku", "~> 2.23.0"
  gem "taps", "~> 0.3.23"
  gem "capistrano", "~> 2.11.2"
  gem "capistrano-ext", "~> 1.2.1"
  gem "soloist", "~> 0.9.4"
  gem "fog", "~> 1.3.1"
  gem "pivotal_git_scripts", "~> 1.1.4"
end

group :test do
  gem "headless", "0.1.0"
end

group :test, :development do
  gem "awesome_print"
  gem "jslint_on_rails", git: "git://github.com/psionides/jslint_on_rails.git", tag: "1.1.1"
  gem "rspec-rails", "~> 2.9.0"
  gem "shoulda-matchers", "~> 1.0.0"
  gem "capybara", "~> 1.1.2"
  gem "jasmine", "~> 1.1.2"
  gem "factory_girl_rails"
  gem "ffaker"
  gem "ruby-debug19"
  gem "pry"
end
