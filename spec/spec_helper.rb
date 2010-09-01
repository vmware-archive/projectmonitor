ENV["RAILS_ENV"] = "test"
dir = File.dirname(__FILE__)
require File.expand_path(dir + "/../config/environment") unless defined?(RAILS_ROOT)
require 'spec'
require 'spec/rails'
require 'mock_clock'
require 'rspec_extensions/spec_helper_matchers'

Spec::Runner.configure do |configuration|
  configuration.use_transactional_fixtures = true
  configuration.use_instantiated_fixtures  = false
  configuration.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  configuration.global_fixtures = :all
  configuration.include AuthenticatedTestHelper
end

Spec::Runner.configuration.before(:all, :behaviour_type => :controller) do
  @integrate_views = true
end

Spec::Runner.configuration.before(:each, :behaviour_type => :controller) do
  self.class.module_eval do
    def log_in(user)
      controller.send("current_user=", user)
    end
  end
end
