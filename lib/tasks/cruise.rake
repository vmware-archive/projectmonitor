Rake.application.clean_task("cruise")

task :cruise => :environment do
  # NOTE: This probably won't actually work, because the Rails environment will fail anyway if gems have not
  # yet been installed.  There needs to be a hook in preinitializer.rb for bundle install to run
  # but only in the CI environment (so it doesn't have to be done on every app/test startup).
  if DEPENDENCY_TOOL == :geminstaller
    require 'geminstaller'
    GemInstaller.install(['--sudo'])
  else
    system('bundle install') || raise("'bundle install' command failed.")
  end
  Rake::Task["db:migrate"].invoke # TODO: remove :reset when migrations stabilize
  Rake::Task["db:test:prepare"].invoke # TODO: remove :reset when migrations stabilize
  Rake::Task["default"].invoke # rake db:test:prepare invokes db:bootstrap
end