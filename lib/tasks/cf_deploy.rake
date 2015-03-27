require 'cf_deploy'

desc "Securely deploy to Cloud Foundry: tag commits and require confirmation"
task :cf_deploy, :deploy_env do |t, args|
  CF_deploy.new(STDIN, STDOUT, args.deploy_env).deploy_to_env

end
