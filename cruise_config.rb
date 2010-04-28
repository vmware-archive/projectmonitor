# Project-specific configuration for CruiseControl.rb
require 'fileutils'

Project.configure do |project|
  FileUtils.cp File.join(project.path, 'work', 'config', 'database.yml.example'), File.join(project.path, 'work', 'config', 'database.yml')
  FileUtils.cp File.join(project.path, 'work', 'config', 'initializers', 'site_keys.rb.example'), File.join(project.path, 'work', 'config', 'initializers', 'site_keys.rb')
  project.email_notifier.emails = ["pivotal-cimonitor@example.com"]
  ENV['CRUISE_PROJECT_NAME'] = project.name
end
