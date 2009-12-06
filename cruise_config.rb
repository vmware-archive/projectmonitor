# Project-specific configuration for CruiseControl.rb
require 'fileutils'

Project.configure do |project|
  project.email_notifier.emails = ["ops+pulse-ci@pivotallabs.com"]
  ENV['CRUISE_PROJECT_NAME'] = project.name
end
