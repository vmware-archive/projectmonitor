require 'spec_helper'

describe ProjectUpdater do
  let(:project) { build(:jenkins_project) }
  let(:payload_log_entry) { PayloadLogEntry.new(status: 'successful') }
  let(:payload_processor) { double(PayloadProcessor, process_payload: payload_log_entry ) }
  let(:payload) { double(Payload, 'status_content=' => nil, 'build_status_content=' => nil) }
  let(:polling_strategy_factory) { double(:polling_strategy_factory) }
  let(:polling_strategy) { double(:polling_strategy) }
  let(:project_updater) { ProjectUpdater.new(payload_processor, polling_strategy_factory) }

  describe '#update' do
    before do
      allow(project).to receive(:fetch_payload).and_return(payload)
      allow(PayloadProcessor).to receive(:new).and_return(payload_processor)
      allow(EM).to receive(:run).and_yield
      allow(EM).to receive(:stop)
      allow(polling_strategy_factory).to receive(:build_ci_strategy).and_return(polling_strategy)
      allow(polling_strategy).to receive(:fetch_status).with(project, anything)
    end

    it 'should process the payload' do
      expect(payload_processor).to receive(:process_payload).with(project: project, payload: payload)

      project_updater.update(project)
    end

    it 'should fetch the feed_url' do
      expect(polling_strategy).to receive(:fetch_status).with(project, project.feed_url)

      project_updater.update(project)
    end

    describe 'on an unsaved project' do
      it 'should not create a payload log entry' do
        expect { project_updater.update(project) }.not_to change(PayloadLogEntry, :count)
      end
    end

    describe 'on a persisted project' do
      before do
        project.save!
      end

      it 'should create a payload log entry' do
        expect { project_updater.update(project) }.to change(PayloadLogEntry, :count).by(1)
      end
    end

    context 'when fetching the status succeeds' do
      before do
        allow(polling_strategy).to receive(:fetch_status).with(project, project.feed_url).and_yield(PollState::SUCCEEDED, 'feed-status', 200)
      end

      it 'should return the log entry' do
        expect(project_updater.update(project)).to eq(payload_log_entry)
      end

      it 'should set the payloads status_content' do
        expect(payload).to receive(:status_content=).with('feed-status')

        project_updater.update(project)
      end

      it 'should stop the EventMachine run loop' do
        expect(EM).to receive(:stop)
        project_updater.update(project)
      end
    end

    context 'when fetching the status fails' do
      before do
        allow(polling_strategy).to receive(:fetch_status).with(project, project.feed_url).and_yield(PollState::FAILED, 'authorization failed', 401)
      end

      it 'should create a payload log entry' do
        expect do
          project_updater.update(project)
          project.save!
        end.to change(PayloadLogEntry, :count).by(1)

        expect(PayloadLogEntry.last.status).to eq('failed')
      end

      it 'should save a useful error message' do
        project_updater.update(project)
        project.save!

        expect(PayloadLogEntry.last.error_text).to eq("Got 401 response status from http://www.example.com/job/project/rssAll, body = 'authorization failed'")
      end

      it 'should set the project to offline' do
        expect(project).to receive(:online=).with(false)

        project_updater.update(project)
      end

      it 'should set the project as not building' do
        expect(project).to receive(:building=).with(false)

        project_updater.update(project)
      end

      it 'should stop the EventMachine run loop' do
        expect(EM).to receive(:stop)
        project_updater.update(project)
      end
    end

    context 'when the project has a different url for status and building status' do
      before do
        allow(project).to receive(:feed_url).and_return('http://status.com')
        allow(project).to receive(:build_status_url).and_return('http://build-status.com')
        allow(polling_strategy).to receive(:fetch_status).with(project, project.build_status_url).and_yield(PollState::SUCCEEDED, 'build-status', 200)
      end

      it 'should fetch the build_status_url' do
        expect(polling_strategy).to receive(:fetch_status).with(project, project.build_status_url)

        project_updater.update(project)
      end

      it 'should set the payloads build_status_content' do
        expect(payload).to receive(:build_status_content=).with('build-status')

        project_updater.update(project)
      end

      context 'and fetching the build status fails' do
        before do
          allow(polling_strategy).to receive(:fetch_status).with(project, project.feed_url).and_yield(PollState::SUCCEEDED, '{}', 200)
          allow(polling_strategy).to receive(:fetch_status).with(project, project.build_status_url).and_yield(PollState::FAILED, '{}', 500)
        end

        it 'should set the project to offline' do
          expect(project).to receive(:online=).with(false)

          project_updater.update(project)
        end

        it 'should leave the project as building' do
          expect(project).to receive(:building=).with(false)

          project_updater.update(project)
        end
      end
    end
  end
end
