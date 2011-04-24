ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.global_fixtures = :messages, :project_statuses, :projects, :taggings, :tags, :users, :aggregate_projects

  config.include AuthenticatedTestHelper
  config.include(ControllerTestHelper, :type => :controller)
  config.include ObjectMother
  config.include CiMonitorSpec::Rails::Matchers

  config.before(:all, :type => :controller) do
    @render_views = true
  end

  config.before(:each) do
    AuthConfig.reset!
  end

end
