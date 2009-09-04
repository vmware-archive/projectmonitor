# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

def overriding_task(arg, &block)
  task_name = arg.is_a?(Hash) ? arg.keys.first : arg
  if Rake::Task.task_defined? task_name
    Rake.application.task_hash["#{task_name}_for_common"] = Rake.application.task_hash["#{task_name}"]
    Rake.application.task_hash["#{task_name}"] = nil
  end
  task(arg, &block)
end

require 'tasks/rails'

Rake.application.options.trace = true
