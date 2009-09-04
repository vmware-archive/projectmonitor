ENV["RAILS_ENV"] ||= "test"

dir = File.dirname(__FILE__)
embedding_rails_root = "#{dir}/.."

require "#{embedding_rails_root}/vendor/plugins/pivotal_core_bundle/lib/remove_textmate_from_load_path"

require File.expand_path(embedding_rails_root + "/config/environment")

require 'hpricot'
require 'test/unit/ui/console/testrunner'
require "test_help"

require 'pivotal_rails_test/quick_feedback_runner'
require 'pivotal_rails_test/common_test_helper'
require 'pivotal_rails_test/mock_flash_hash'
require 'thoughtworks/file_sandbox'
require 'thoughtworks/file_sandbox_behavior'

require 'mocha'
module Pulse
  class RailsTestCase < ActiveSupport::TestCase
    fixtures :all
    self.use_transactional_fixtures = true
    self.use_instantiated_fixtures  = false

    include CommonTestHelper

    setup :reset_clock_mock
    setup :set_mock_flash
    setup :clear_email_deliveries
  end
end

