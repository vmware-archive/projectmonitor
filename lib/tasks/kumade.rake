namespace :kumade do
  task :pre_deploy do
    revision_path    = File.join(Rails.root, 'REVISION')

    File.write(revision_path, `git rev-parse HEAD`)

    system("git checkout -b #{Kumade::Heroku::DEPLOY_BRANCH}") &&
      system("git add #{revision_path}") &&
      system("git commit -m 'Adding REVISION file for Heroku'")
  end
end
