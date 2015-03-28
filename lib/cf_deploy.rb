class CF_deploy
  require 'cf_authenticator'
  require 'cf_git_tagger'

  ENV_HASH = {:staging => 'project-monitor-staging', :production => 'project-monitor-production'}

  def initialize(stdin, stdout, env, cf_authenticator = CF_authenticator.new(), cf_git_tagger = CF_git_tagger.new())
    if env == nil
      puts "Exit Code 1: Please supply a deployment environment name and try again. \nExample: 'rake cf_deploy[staging]'"
      exit(1)
    end
    @stdin = stdin
    @stdout = stdout
    @actual_env = ENV_HASH[env.to_sym]
    @authenticator = cf_authenticator
    @git_tagger = cf_git_tagger
  end

  def deploy_to_env
    if @actual_env == nil
      puts "Exit Code 1: Invalid deployment environment. Possible environments include 'staging' and 'production'"
      exit(1)
    end

    if @actual_env == "project-monitor-production"
      confirm_deploy
    end
    if @actual_env == "project-monitor-staging"
      execute_deploy
    end

  end

  def confirm_deploy
    begin
      puts "Are you sure you want to deploy to #{@actual_env}? (y/n)"
      input = @stdin.gets.strip.downcase
    end until %w(y n).include?(input)

    if input == 'n'
      puts 'exiting'
    end
    if input == 'y'
      execute_deploy
    end
  end

  def execute_deploy
    @stdout.puts "Deploying to #{@actual_env}"
    authenticate
    git_tag
    push_to_cf
  end

  def authenticate
    username = wait_for_input_with('CF Email?: ')
    puts 'CF Password?: '
    password = @stdin.noecho(&:gets).chomp
    @authenticator.authenticate_with(username,password)
  end

  def git_tag
    sha = `git rev-parse HEAD`.chomp
    tag_name = Time.now.strftime("%d-%m-%Y--%H-%M")
    @git_tagger.tag_commit_with_message tag_name, sha, "pushing to #{@actual_env}"
  end

  private
  def wait_for_input_with(question)
    puts question
    @stdin.gets.chomp
  end

  def push_to_cf
    puts 'pushing to Cloud Foundry...'
    if @actual_env === 'project-monitor-staging'
      puts `cf push project-monitor-staging -f config/cf/manifest-staging.yml`
    end
    if @actual_env === 'project-monitor-production'
      puts `cf push project-monitor-production -f config/cf/manifest-production.yml`
    end
    puts `cf logout`
  end

end