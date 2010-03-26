Rake.application.clean_task("cruise")

task :cruise => :environment do
  Rake::Task["db:migrate"].invoke # TODO: remove :reset when migrations stabilize
  Rake::Task["db:test:prepare"].invoke # TODO: remove :reset when migrations stabilize
  Rake::Task["default"].invoke # rake db:test:prepare invokes db:bootstrap
end