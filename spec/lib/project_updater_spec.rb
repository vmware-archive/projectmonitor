require 'spec_helper'

describe ProjectUpdater do
  let(:project) { build(:jenkins_project) }
  let(:net_exception) { Net::HTTPError.new('Server error', 501) }
  let(:payload_log_entry) { PayloadLogEntry.new(status: "successful") }
  let(:payload_processor) { double(PayloadProcessor, process_payload: payload_log_entry ) }
  let(:payload) { double(Payload, 'status_content=' => nil, 'build_status_content=' => nil) }
  let(:project_updater) { ProjectUpdater.new(payload_processor: payload_processor) }

  describe '.update' do
    before do
      allow(project).to receive(:fetch_payload).and_return(payload)
      allow(UrlRetriever).to receive(:new).with(any_args).and_return(double('UrlRetriever', retrieve_content: 'response'))
      allow(PayloadProcessor).to receive(:new).and_return(payload_processor)
    end

    it 'should process the payload' do
      expect(payload_processor).to receive(:process_payload).with(project: project, payload: payload)

      project_updater.update(project)
    end

    it 'should fetch the feed_url' do
      retriever = double('UrlRetriever')
      allow(UrlRetriever).to receive(:new).with(project.feed_url, project.auth_username, project.auth_password, project.verify_ssl).and_return(retriever)
      expect(retriever).to receive(:retrieve_content)

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
      let(:payload_log_entry) { double(PayloadLogEntry, :save! => nil, :update_method= => nil) }

      it('should return the log entry') do
        expect(project_updater.update(project)).to eq(payload_log_entry)
      end
    end

    context 'when fetching the status fails' do
      before do
        retriever = double('UrlRetriever')
        allow(UrlRetriever).to receive(:new).with(project.feed_url, project.auth_username, project.auth_password, project.verify_ssl).and_return(retriever)
        allow(retriever).to receive(:retrieve_content).and_raise(net_exception)
      end

      it 'should create a payload log entry' do
        expect do
          project_updater.update(project)
          project.save!
        end.to change(PayloadLogEntry, :count).by(1)

        expect(PayloadLogEntry.last.status).to eq("failed")
      end

      it 'should set the project to offline' do
        expect(project).to receive(:online=).with(false)

        project_updater.update(project)
      end

      it 'should set the project as not building' do
        expect(project).to receive(:building=).with(false)

        project_updater.update(project)
      end
    end

    context 'when the project has a different url for status and building status' do
      before do
        allow(project).to receive(:feed_url).and_return('http://status.com')
        allow(project).to receive(:build_status_url).and_return('http://build-status.com')
      end

      it 'should fetch the build_status_url' do
        retriever = double('UrlRetriever')
        allow(UrlRetriever).to receive(:new).with(project.feed_url, project.auth_username, project.auth_password, project.verify_ssl).and_return(retriever)
        expect(retriever).to receive(:retrieve_content)

        project_updater.update(project)
      end

      context 'and fetching the build status fails' do
        before do
          retriever = double('UrlRetriever')
          allow(UrlRetriever).to receive(:new).with(project.feed_url, project.auth_username, project.auth_password, project.verify_ssl).and_return(retriever)
          allow(retriever).to receive(:retrieve_content).and_raise(net_exception)
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
