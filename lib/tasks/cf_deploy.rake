require 'cf_deploy'

desc "Securely deploy to Cloud Foundry: tag commits and require confirmation"
task :cf_deploy, :deploy_env do |t, args|
  puts "starting deploy to #{args.deploy_env}"
  authenticator = CF_authenticator.new()
  tagger = CF_git_tagger.new()
  CF_deploy.new(STDIN, STDOUT, args.deploy_env.to_s, authenticator, tagger).deploy_to_env

end
