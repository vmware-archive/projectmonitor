require 'spec_helper'

describe ProjectUpdater do

  let(:project) { FactoryGirl.build(:jenkins_project) }
  let(:net_exception) { Net::HTTPError.new('Server error', 500) }
  let(:payload_log_entry) { PayloadLogEntry.new }
  let(:payload_processor) { double(PayloadProcessor, process: payload_log_entry ) }
  let(:payload) { double(Payload, 'status_content=' => nil, 'build_status_content=' => nil, 'dependent_content=' => nil) }

  describe '.update' do
    before do
      project.stub(:fetch_payload).and_return(payload)
      UrlRetriever.stub(:retrieve_content_at)
      PayloadProcessor.stub(:new).and_return(payload_processor)
    end

    subject { ProjectUpdater.update(project) }

    it 'should process the payload' do
      payload_processor.should_receive(:process)
      subject
    end

    it 'should fetch the feed_url' do
      UrlRetriever.should_receive(:retrieve_content_at).with(project.feed_url, project.auth_username, project.auth_password)
      subject
    end

    it 'should create a payload log entry' do
      expect { subject }.to change(PayloadLogEntry, :count).by(1)
    end

    context 'when fetching the status succeeds' do
      let(:payload_log_entry) { double(PayloadLogEntry, :save! => nil, :method= => nil) }
      subject { ProjectUpdater.update(project) }
      it('should return the log entry') { should == payload_log_entry }
    end

    context 'when fetching the status fails' do
      before do
        UrlRetriever.stub(:retrieve_content_at).with(project.feed_url, project.auth_username, project.auth_password).and_raise(net_exception)
      end

      it 'should create a payload log entry' do
        expect { subject; project.save! }.to change(PayloadLogEntry, :count).by(1)
        PayloadLogEntry.last.status.should == "failed"
      end

      it 'should set the project to offline' do
        project.should_receive(:online=).with(false)
        subject
      end

      it 'should set the project as not building' do
        project.should_receive(:building=).with(false)
        subject
      end
    end

    context 'when the project has a different url for status and building status' do
      before do
        project.stub(:feed_url).and_return('http://status.com')
        project.stub(:build_status_url).and_return('http://build-status.com')
      end

      it 'should fetch the build_status_url' do
        UrlRetriever.should_receive(:retrieve_content_at).with(project.build_status_url, project.auth_username, project.auth_password)
        subject
      end

      context 'and fetching the build status fails' do
        before do
          UrlRetriever.stub(:retrieve_content_at).with(project.build_status_url, project.auth_username, project.auth_password).and_raise(net_exception)
        end

        it 'should set the project to offline' do
          project.should_receive(:online=).with(false)
          subject
        end

        it 'should leave the project as building' do
          project.should_receive(:building=).with(false)
          subject
        end
      end
    end

    context 'when the project has dependent children' do
      let(:dependent_project) { double }

      before do
        project.stub(:dependent_projects).and_return([dependent_project])
      end

      context 'and is persisted' do
        before do
          project.stub(:persisted?).and_return(true)
        end

        context 'and has a dependent build info url' do
          before do
            project.stub(:dependent_build_info_url).and_return(true)
          end

          it 'should update the dependent children' do
            ProjectUpdater.should_receive(:update_dependent).with(dependent_project)
            subject
          end
        end

        context 'and has no dependent build info url' do
          before do
            project.stub(:dependent_build_info_url).and_return(false)
          end

          it 'should not update the dependent children' do
            ProjectUpdater.should_not_receive(:update_dependent)
            subject
          end
        end
      end

      context 'and is not persisted' do
        before do
          project.stub(:persisted?).and_return(false)
        end

        it 'should not update the dependent children' do
          ProjectUpdater.should_not_receive(:update_dependent)
          subject
        end
      end
    end
  end

end
