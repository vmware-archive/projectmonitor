# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'

module Rake
  module TaskManager
    def clean_task(name)
      @tasks[name] = nil
    end
  end
end

require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

Rake.application.options.trace = true
