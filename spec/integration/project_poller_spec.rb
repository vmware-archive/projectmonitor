require 'spec_helper'

describe ProjectPoller do

  subject { ProjectPoller.new }

  describe '#run_once' do
    before do
      Project.delete_all
    end

    it 'should update ci projects (even when there are no projects with tracker integrations)' do
      create(:jenkins_project, ci_base_url: 'https://jenkins.mono-project.com', ci_build_identifier: 'test-gtksharp-mainline-2.12')
      log_entry_count = PayloadLogEntry.count

      VCR.use_cassette('poller_run_once') do
        subject.run_once
      end

      puts PayloadLogEntry.all.inspect
      expect(PayloadLogEntry.count).to eq(log_entry_count + 1)
    end

    it 'should update tracker projects' do
      project = create(:project_with_tracker_integration, tracker_project_id: '2872', tracker_auth_token: 'secret-tracker-api-key')
      project.update_attributes(ci_base_url: 'https://jenkins.mono-project.com', ci_build_identifier: 'test-gtksharp-mainline-2.12')

      VCR.use_cassette('poller_tracker_run_once') do
        subject.run_once
      end

      p = Project.find(project.id)
      expect(p.current_velocity).to eq(1)
      expect(p.last_ten_velocities).to eq([0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
      expect(p.iteration_story_state_counts).to eq [{"label"=>"unstarted", "value"=>0},
                                                    {"label"=>"started", "value"=>8},
                                                    {"label"=>"finished", "value"=>0},
                                                    {"label"=>"delivered", "value"=>0},
                                                    {"label"=>"accepted", "value"=>0},
                                                    {"label"=>"rejected", "value"=>0}]
      expect(p.tracker_online).to eq(true)
    end

    it 'should exit gracefully when there are no projects' do
      Project.delete_all

      subject.run_once

      expect(true).to eq(true)
    end
  end
end
