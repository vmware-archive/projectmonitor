ENV["RAILS_ENV"] = 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'webmock/rspec'
require 'capybara/rspec'
require 'capybara/rails'
require 'pry'

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = false
  config.use_instantiated_fixtures  = false
  config.global_fixtures = :project_statuses, :projects, :taggings, :tags, :aggregate_projects

  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include ViewHelpers, type: :view

  config.order = 'random'
  config.include Rails.application.routes.url_helpers

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  Capybara.javascript_driver = :webkit

  config.before(:all) do
    DeferredGarbageCollection.start
  end

  config.after(:all) do
    DeferredGarbageCollection.reconsider
  end
end
