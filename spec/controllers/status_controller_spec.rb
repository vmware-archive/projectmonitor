require 'spec_helper'

describe StatusController do
  describe "#create" do

    context "Travis project" do
      let!(:project) { FactoryGirl.create(:travis_project) }
      let(:successful_payload) do
        URI.encode(open('spec/fixtures/travis_examples/success.json').read.gsub("4314974", "4219108"))
      end
      let(:failure_payload) do
        URI.encode(open('spec/fixtures/travis_examples/failure.json').read)
      end
      let(:on_start_payload) do
        URI.encode(open('spec/fixtures/travis_examples/created.json').read)
      end

      subject { post :create, project_id: project.guid, payload: successful_payload }

      it "should create a new status" do
        expect { subject }.to change(ProjectStatus, :count).by(1)
      end

      it "should log a payload log" do
        expect { subject }.to change(PayloadLogEntry, :count).by(1)
      end

      it "doesn't create new status recores for 'on_start' notifications" do
        expect {
          post :create, project_id: project.guid, payload: on_start_payload
        }.not_to change(ProjectStatus, :count)
      end

      it "also creates a new status when it receives successful notification after failure" do
        post :create, project_id: project.guid, payload: failure_payload

        expect {
          post :create, project_id: project.guid, payload: successful_payload
        }.to change { project.status.success }.from(false).to(true)
      end

      it "creates only one new status" do
        expect {
          subject
          subject
        }.to change(ProjectStatus, :count).by(1)
      end

      it "should have all the attributes" do
        post :create, project_id: project.guid, payload: failure_payload

        ProjectStatus.last.should_not be_success
        ProjectStatus.last.project_id.should == project.id
        ProjectStatus.last.published_at.to_s.should == Time.utc(2013, 1, 21, 16, 12, 15).to_s
      end

      it "should update last_refreshed_at" do
        project.last_refreshed_at.should be_nil
        subject
        project.reload.last_refreshed_at.should_not be_nil
      end

      it "should update parsed_url" do
        project.parsed_url.should be_nil
        subject
        project.reload.parsed_url.should == 'https://travis-ci.org/account/project/builds/4219108'
      end
    end

    context "Jenkins project" do
      let!(:project) { FactoryGirl.create(:project) }
      let(:build_id) { 7 }
      let(:build_url) { "job/projectmonitor_ci_test/#{build_id}/" }
      let(:parsed_url) { "job/projectmonitor_ci_test/" }
      let(:payload) do
        %Q{{"name":"projectmonitor_ci_test",
        "url":"job/projectmonitor_ci_test/",
        "build":{"number":#{build_id},"phase":"FINISHED",
        "status":"FAILURE",
        "url":"#{build_url}"}}}
      end

      shared_examples_for "a Jenkins webhook build" do
        it "should create a new status" do
          expect { subject }.to change(ProjectStatus, :count).by(1)
        end

        it "creates only one new status" do
          expect {
            subject
            subject
          }.to change(ProjectStatus, :count).by(1)
        end

        it "should have all the attributes" do
          subject
          ProjectStatus.last.should_not be_success
          ProjectStatus.last.project_id.should == project.id
          ProjectStatus.last.build_id.should == build_id
          ProjectStatus.last.published_at.should_not be_nil
        end

        it "should update parsed_url" do
          project.parsed_url.should be_nil
          subject
          project.reload.parsed_url.should include parsed_url
        end
      end

      context "payload sent as raw post data (deprecated)" do
        subject do
          request.env['RAW_POST_DATA'] = payload
          post :create, project_id: project.guid
        end

        it_behaves_like "a Jenkins webhook build"
      end

      context "payload sent as params" do
        subject do
          post :create, JSON.parse(payload).merge(project_id: project.guid)
        end

        it_behaves_like "a Jenkins webhook build"
      end
    end

    context "TeamCity Rest project" do
      let!(:project) { FactoryGirl.create(:team_city_rest_project) }
      let(:payload) do
        {
          "buildStatus"=> "Running",
          "buildResult"=> "success",
          "notifyType"=> "buildFinished",
          "buildRunner"=> "Command Line",
          "buildFullName"=> "My Awesome Project :: RUN IT",
          "buildName"=> "RUN IT",
          "buildId"=> "13",
          "buildTypeId"=> "bt2",
          "projectName"=> "My Awesome Project",
          "projectId"=> "project2",
          "buildNumber"=> "7",
          "agentName"=> "Default Agent",
          "agentOs"=> "Mac OS X, version 10.7.4",
          "agentHostname"=> "localhost",
          "triggeredBy"=> "Dude",
          "message"=> "Build My Awesome Project :: RUN IT has finished. This is build number 7, has a status of \"Running\" and was triggered by Dude",
          "text"=> "My Awesome Project :: RUN IT has finished. Status: Running"
        }
      end

      subject do
        post :create, project_id: project.guid, build: payload
      end

      it "should create a new status" do
        expect { subject }.to change(ProjectStatus, :count).by(1)
      end

      it "creates only one new status" do
        expect {
          subject
          subject
        }.to change(ProjectStatus, :count).by(1)
      end

      it "should have all the attributes" do
        subject
        ProjectStatus.last.should be_success
        ProjectStatus.last.project_id.should == project.id
        ProjectStatus.last.build_id.should == 13
        ProjectStatus.last.published_at.should_not be_nil
      end

      it "should update parsed_url" do
        project.parsed_url.should be_nil
        subject
        project.reload.parsed_url.should include 'bt2'
      end
    end

    context 'when processing the payload succeeded' do
      let(:project) { FactoryGirl.build(:jenkins_project, guid: '1')}

      let(:payload) do
        {'name'  => 'projectmonitor_ci_test',
         'url'    => 'job/projectmonitor_ci_test/',
         'build'  => {
           'number' => 7,
           'phase'  => 'FINISHED',
           'status' => 'FAILURE',
           'url'    => 'job/projectmonitor_ci_test/7/'}}
      end

      before do
        Project.stub(:find_by_guid).and_return(project)
      end

      after do
        post :create, payload.merge(project_id: project.guid)
      end

      it 'should set last_refreshed_at' do
        project.should_receive(:last_refreshed_at=)
      end

      it 'should save the project' do
        project.should_receive(:save!)
      end
    end

    context 'when processing the payload failed' do

      let(:project) { FactoryGirl.build(:jenkins_project, guid: '1')}

      before do
        Project.stub(:find_by_guid).and_return(project)
      end

      it 'should save the project with its original last_refreshed_at date' do
        project.should_receive(:save!)
        project.should_not_receive(:last_refreshed_at=)

        post :create, project_id: project.guid, "payload" => 'invalid_post_content'
      end

    end

    context "when a project isn't found" do
      it "should return a 404" do
        post :create, project_id: "1234", "payload" => '{"id": 4219108}'
        response.response_code.should == 404
      end
    end

  end
end
