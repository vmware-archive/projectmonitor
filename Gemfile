source :rubygems
gem "bundler"

gem "rails", "~> 2.3.10"
gem "rake"
gem "gem_plugin"
gem "mime-types"
gem "fastthread"
gem "nokogiri"
gem "httpauth"
gem "acts_as_taggable_on_steroids"
gem "ruby-openid"
gem "ruby-openid-apps-discovery"
gem "rspec", "~> 1.3.0"
gem "rspec-rails", "~> 1.3.2"
gem "delayed_job"

group :postgres do
  gem "pg"
end

group :mysql do
  gem "mysql"   ### assume in system gems
end

group :development do
  gem "heroku"
  gem "sqlite3-ruby"
  gem "mongrel", "~> 1.2.0.pre2"
  gem "mongrel_cluster"
  gem 'ruby-debug-base19' if RUBY_VERSION.include? "1.9"
  gem 'ruby-debug-base' if RUBY_VERSION.include? "1.8"
  gem "ruby-debug-ide"
end

group :test do
  gem "jasmine"
  gem "mongrel", "~> 1.2.0.pre2"
  gem "mongrel_cluster"
  gem 'ruby-debug-base19' if RUBY_VERSION.include? "1.9"
  gem 'ruby-debug-base' if RUBY_VERSION.include? "1.8"
  gem "ruby-debug-ide"
end