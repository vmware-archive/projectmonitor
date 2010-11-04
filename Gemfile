source :rubygems
gem "bundler", "~> 1.0.0"

gem "rails", "2.3.5"
gem "rack", "1.0.1"
gem "rake", "0.8.7"
gem "gem_plugin", "0.2.3"
gem "mime-types", "1.16"
gem "fastthread", "1.0.7"
gem "nokogiri", "1.4.2"
gem "httpauth", "0.1"
gem "acts_as_taggable_on_steroids", "1.1"
gem "ruby-openid", "2.1.8"
gem "ruby-openid-apps-discovery", "1.2.0"
gem "rspec", "1.3.0"
gem "rspec-rails", "1.3.2"
gem "delayed_job", "2.0.3"

group :postgres do
  gem "pg", "0.9.0"
end

group :mysql do
  gem "mysql", ">= 2.8.0"   ### assume in system gems
end

group :development do
  gem "heroku", "1.11.0"
  gem "sqlite3-ruby"
  gem "mongrel", ">= 1.1.5"
  gem "mongrel_cluster", "1.0.5"
  gem 'ruby-debug-base19' if RUBY_VERSION.include? "1.9"
  gem 'ruby-debug-base' if RUBY_VERSION.include? "1.8"
  gem "ruby-debug-ide"
end

group :test do
  gem "jasmine", "0.10.3.1"
  gem "mongrel", ">= 1.1.5"
  gem "mongrel_cluster", "1.0.5"
  gem 'ruby-debug-base19' if RUBY_VERSION.include? "1.9"
  gem 'ruby-debug-base' if RUBY_VERSION.include? "1.8"
  gem "ruby-debug-ide"
end
