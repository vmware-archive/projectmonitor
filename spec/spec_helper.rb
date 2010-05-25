# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
dir = File.dirname(__FILE__)
require File.expand_path(dir + "/../config/environment") unless defined?(RAILS_ROOT)
require 'spec'
require 'spec/rails'
require 'mock_clock'
require 'rspec_extensions/spec_helper_matchers'
require 'xml/libxml'

Spec::Runner.configure do |configuration|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  configuration.use_transactional_fixtures = true
  configuration.use_instantiated_fixtures  = false
  configuration.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  configuration.global_fixtures = :all
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # You can also declare which fixtures to use (for example fixtures for test/fixtures):
  #
  # configuration.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # configuration.mock_with :mocha
  # configuration.mock_with :flexmock
  # configuration.mock_with :rr
  #
  # == Notes
  #
  # For more information take a look at Spec::Example::Configuration and Spec::Runner
end

# This is here to allow spec helpers to work with spec_server
#spec_helpers_dir = File.dirname(__FILE__) + "/spec_helpers"
#$LOAD_PATH.unshift spec_helpers_dir
#Dependencies.load_paths.unshift(spec_helpers_dir)
#Dir["#{spec_helpers_dir}/**/*.rb"].each do |file|
# require_dependency file
#end

# This is here to allow you to integrate views on all of your controller specs
Spec::Runner.configuration.before(:all, :behaviour_type => :controller) do
  @integrate_views = true
end

# This is here to allow you to mock flash on all of your controller specs
Spec::Runner.configuration.before(:all, :behaviour_type => :controller) do
#  set_mock_flash
end

Spec::Runner.configuration.before(:each, :behaviour_type => :controller) do
  self.class.module_eval do
    def log_in(user)
      controller.send("current_user=", user)
    end
  end
end

include AuthenticatedTestHelper
