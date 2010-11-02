ENV["RAILS_ENV"] ||= "test"
require File.expand_path(File.join(File.dirname(__FILE__),'..','config','environment'))
require 'spec'
require 'spec/autorun'
require 'spec/rails'
require 'nokogiri'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

Spec::Runner.configure do |configuration|
  configuration.use_transactional_fixtures = true
  configuration.use_instantiated_fixtures  = false
  configuration.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  configuration.global_fixtures = :all
  configuration.include AuthenticatedTestHelper
  configuration.include(ControllerTestHelper, :type => :controller)
  configuration.include(ObjectMother)
  configuration.before(:all, :type => :controller) do
    @integrate_views = true
  end
  configuration.before(:each) do
    AuthConfig.reset!
    AuthConfig.stub(:auth_file_path).and_return(Rails.root.join("spec/fixtures/files/auth-false.yml"))
  end
end

