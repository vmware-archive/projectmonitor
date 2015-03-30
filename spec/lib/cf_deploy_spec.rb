require 'spec_helper'

describe CF_deploy do

  describe 'basic argument validation' do
    it 'should terminate if the user does not enter a deployment environment name' do
      exit_message = `rake cf_deploy`
      expect(exit_message).to include('Exit Code 1:')
    end
  end

  describe 'confirming user input for build' do

    default_output_string = "Are you sure you want to deploy to project-monitor-production? (y/n)\n"
    exit_output_string = default_output_string + "exiting\n"

    it 'should move on if the user types "y"' do
      stdin_double = double(STDIN)
      allow(stdin_double).to receive(:gets) { 'y' }

      cf_deploy_under_test = CF_deploy.new(stdin_double, STDOUT, 'pivotallabs', 'project-monitor', 'project-monitor-production')
      allow(cf_deploy_under_test).to receive(:execute_deploy) {}
      expect { cf_deploy_under_test.confirm_deploy }.to output(default_output_string).to_stdout
    end

    it 'should end if the user types "n"' do
      stdin_double = double(STDIN)
      allow(stdin_double).to receive(:gets) { 'n' }

      cf_deploy_under_test = CF_deploy.new(stdin_double, STDOUT, 'pivotallabs', 'project-monitor', 'project-monitor-production')
      expect { cf_deploy_under_test.confirm_deploy }.to output(exit_output_string).to_stdout
    end

    it 'should repeat if the user types anything else' do
      stdin_double = double(STDIN)
      allow(stdin_double).to receive(:gets).and_return('o', 'hola', 'n')

      cf_deploy_under_test = CF_deploy.new(stdin_double, STDOUT, 'pivotallabs', 'project-monitor', 'project-monitor-production')
      expect { cf_deploy_under_test.confirm_deploy }.to output(default_output_string+default_output_string+exit_output_string).to_stdout
    end
  end


  describe 'authenticating with CloudFoundry' do
    it 'should prompt the user for a username and password and authenticate with those inputs' do
      stdin_double = double(STDIN)
      randString1 = rand(36**20).to_s(36)
      randString2 = rand(36**20).to_s(36)
      allow(stdin_double).to receive(:gets).and_return(randString1, randString2)
      allow(stdin_double).to receive(:noecho).and_return(randString2)

      authenticator_double = double(CF_authenticator)
      allow(authenticator_double).to receive(:authenticate_with).and_return(0)

      cf_deploy_under_test = CF_deploy.new(stdin_double, STDOUT, 'pivotallabs', 'project-monitor', 'staging', authenticator_double)
      expect { cf_deploy_under_test.authenticate }.to output("CF Email?: \nCF Password?: \n").to_stdout

      expect(authenticator_double).to have_received(:authenticate_with).with(randString1, randString2, 'pivotallabs', 'project-monitor')
    end
  end

  describe 'tagging git commits' do
    it 'should tag the most recent git commit with a unique message' do
      git_tagger_double = double(CF_git_tagger)
      allow(git_tagger_double).to receive(:tag_commit_with_message).with(any_args)

      cf_deploy_under_test = CF_deploy.new(STDIN, STDOUT, 'pivotallabs', 'poject-monitor', 'project-monitor-staging', CF_authenticator.new(), git_tagger_double)
      cf_deploy_under_test.git_tag
      expect(git_tagger_double).to have_received(:tag_commit_with_message).with(any_args)
    end
  end
end