require 'spec_helper'

describe ProjectUpdater do

  let(:project) { FactoryGirl.build(:jenkins_project) }
  let(:net_exception) { Net::HTTPError.new('Server error', 500) }
  let(:payload_processor) { double(PayloadProcessor, process: nil) }
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

    it 'should update the last_update_at time on the project' do
      project.last_refreshed_at.should be_nil
      subject
      project.last_refreshed_at.should_not be_nil
    end

    it 'should fetch the feed_url' do
      UrlRetriever.should_receive(:retrieve_content_at).with(project.feed_url, project.auth_username, project.auth_password)
      subject
    end

    context 'when fetching the status fails' do
      before do
        UrlRetriever.stub(:retrieve_content_at).with(project.feed_url, project.auth_username, project.auth_password).and_raise(net_exception)
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
      let(:child_payload) { double(Payload).as_null_object }
      let(:child_project) { double(Project, feed_url: 'http://child-status.com', build_status_url: 'http://child-status.com', fetch_payload: child_payload).as_null_object }

      before do
        project.stub(:has_dependencies?).and_return(true)
        payload.stub(:each_child).with(project).and_yield(child_project)
      end

      it 'should fetch the dependent_build_info_url' do
        UrlRetriever.should_receive(:retrieve_content_at).with(project.dependent_build_info_url, project.auth_username, project.auth_password)
        subject
      end

      it 'should update its children' do
        UrlRetriever.should_receive(:retrieve_content_at).with(child_project.feed_url, child_project.auth_username, child_project.auth_password)
        subject
      end

      context 'and a child project is failing' do
        before do
          child_project.stub('red?').and_return(true)
        end

        it 'should set has_failing_children' do
          subject
          project.has_failing_children.should be_true
        end
      end

      context 'and a child project is building' do
        before do
          child_project.stub('building?').and_return(true)
        end

        it 'should set has_building_children' do
          subject
          project.has_building_children.should be_true
        end
      end
    end
  end

end
