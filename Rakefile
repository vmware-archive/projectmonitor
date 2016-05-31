# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

# This is to make 'rake db:fixture:laod' work with the spec directory in Rails 3
ENV['FIXTURES_PATH'] = File.join('spec', 'fixtures')
fixtures_dir = File.join(__FILE__.gsub('Rakefile', ''), ENV['FIXTURES_PATH'])
ENV['FIXTURES'] = Dir["#{fixtures_dir}/*.{yml,csv}"].map {|f| f.gsub(fixtures_dir + "/", '')}.join(",")

require File.expand_path('../config/application', __FILE__)
require 'rake'
ProjectMonitor::Application.load_tasks

begin
  require 'delayed/tasks'
rescue LoadError
  STDERR.puts "Run `rake gems:install` to install delayed_job"
end

task default: [:jshint, "jasmine:ci"]
