namespace :jasmine do
  desc 'Compile coffeescript specs for CI/rake'
  task :compile_coffeescript do
    require 'guard'
    Guard.setup
    Guard::Dsl.evaluate_guardfile(:guardfile => 'Guardfile')

    Guard.guards('coffeescript').run_all
  end
end
