ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'vcr_setup'

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.global_fixtures = :project_statuses, :projects, :taggings, :tags, :users, :aggregate_projects

  config.include AuthenticatedTestHelper

  config.extend VCR::RSpec::Macros

  config.treat_symbols_as_metadata_keys_with_true_values = true

  config.before do
    AuthConfig.reset!
  end
end
