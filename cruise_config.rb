# Project-specific configuration for CruiseControl.rb
require 'fileutils'

Project.configure do |project|
  project.email_notifier.emails = ["chad+pulse-ci@pivotallabs.com"]
  require "#{File.dirname(__FILE__)}/vendor/plugins/pivotal_core_bundle/lib/cruise/pivotal_cruise_config.rb"
  Pivotal::CruiseConfig.config(project)
end
