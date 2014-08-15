ENV["RAILS_ENV"] = 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/rails'
require 'vcr_setup'
require 'pry'
require_relative 'support/view_helpers.rb'

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = false
  config.use_instantiated_fixtures  = false
  config.global_fixtures = :project_statuses, :projects, :taggings, :tags, :aggregate_projects

  config.include Devise::TestHelpers, type: :controller
  config.include ViewHelpers, type: :view

  config.treat_symbols_as_metadata_keys_with_true_values = true

  config.order = 'random'
  config.include Rails.application.routes.url_helpers

  Capybara.javascript_driver = :webkit

  # TODO: This fixes a bug in RSpec, see here:
  # https://github.com/rspec/rspec-rails/issues/252
  def (ActionDispatch::Integration::Session).fixture_path
    RSpec.configuration.fixture_path
  end
end
