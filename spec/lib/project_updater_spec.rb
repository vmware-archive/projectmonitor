require 'spec_helper'

describe ProjectUpdater do

  let(:project) { FactoryGirl.build(:jenkins_project) }
  let(:net_exception) { Net::HTTPError.new('Server error', 501) }
  let(:payload_log_entry) { PayloadLogEntry.new(status: "successful") }
  let(:payload_processor) { double(PayloadProcessor, process: payload_log_entry ) }
  let(:payload) { double(Payload, 'status_content=' => nil, 'build_status_content=' => nil) }

  describe '.update' do
    before do
      project.stub(:fetch_payload).and_return(payload)
      UrlRetriever.stub(:new).with(any_args).and_return(double('UrlRetriever', retrieve_content: 'response'))
      PayloadProcessor.stub(:new).and_return(payload_processor)
    end

    subject { ProjectUpdater.update(project) }

    it 'should process the payload' do
      payload_processor.should_receive(:process)
      subject
    end

    it 'should fetch the feed_url' do
      retriever = double('UrlRetriever')
      UrlRetriever.stub(:new).with(project.feed_url, project.auth_username, project.auth_password, project.verify_ssl).and_return(retriever)
      retriever.should_receive(:retrieve_content)
      subject
    end

    it 'should create a payload log entry' do
      expect { subject }.to change(PayloadLogEntry, :count).by(1)
    end

    context 'when fetching the status succeeds' do
      let(:payload_log_entry) { double(PayloadLogEntry, :save! => nil, :update_method= => nil) }
      subject { ProjectUpdater.update(project) }
      it('should return the log entry') { should == payload_log_entry }
    end

    context 'when fetching the status fails' do
      before do
        retriever = double('UrlRetriever')
        UrlRetriever.stub(:new).with(project.feed_url, project.auth_username, project.auth_password, project.verify_ssl).and_return(retriever)
        retriever.stub(:retrieve_content).and_raise(net_exception)
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
        retriever = double('UrlRetriever')
        UrlRetriever.stub(:new).with(project.feed_url, project.auth_username, project.auth_password, project.verify_ssl).and_return(retriever)
        retriever.should_receive(:retrieve_content)
        subject
      end

      context 'and fetching the build status fails' do
        before do
          retriever = double('UrlRetriever')
          UrlRetriever.stub(:new).with(project.feed_url, project.auth_username, project.auth_password, project.verify_ssl).and_return(retriever)
          retriever.stub(:retrieve_content).and_raise(net_exception)
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

  end

end
