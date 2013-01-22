require 'spec_helper'
describe StatusController do
  describe "#create" do

    context "Travis project" do
      let!(:project) { FactoryGirl.create(:travis_project) }
      let(:payload) do
      '{
        "id": 1879979,
        "slug": "pivotal/projectmonitor",
        "description": "Big Visible Chart CI aggregator",
        "public_key": "-----BEGIN RSA PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCcaBRYqBz7ZKuy2YqhX++C6iXW\nNFU/1KwErPAjx+jAK4wbdUuahOCyR/jkAl/SsHPcZ/H8dBgI8gTqpO4+ki3VpRNw\nGHm8tPJy5D6iRzFY3vv3ZX0WWY4dZwpj5oKdD7tsgHSZxGYY4y4LumspBIUo4BIu\n8tIAF7+AiEvRNiBX/QIDAQAB\n-----END RSA PUBLIC KEY-----\n",
        "last_build_id": 1879978,
        "last_build_number": "308",
        "last_build_status": 1,
        "last_build_result": 1,
        "last_build_duration": 346,
        "last_build_language": null,
        "last_build_started_at": "2013-01-22T01:54:44Z",
        "last_build_finished_at": "2013-01-22T02:00:30Z"
      }'
      end

      subject { post :create, project_id: project.guid, payload: payload }

      it "should create a new status" do
        expect { subject }.to change(ProjectStatus, :count).by(1)
      end

      it "should log a payload log" do
        expect { subject }.to change(PayloadLogEntry, :count).by(1)
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
        ProjectStatus.last.published_at.should == Time.parse("2013-01-22T02:00:30Z")
      end

      it "should update last_refreshed_at" do
        project.last_refreshed_at.should be_nil
        subject
        project.reload.last_refreshed_at.should_not be_nil
      end

      it "should update parsed_url" do
        project.parsed_url.should be_nil
        subject
        project.reload.parsed_url.should == 'https://travis-ci.org/pivotal/projectmonitor'
      end

    end

    context "Jenkins project" do
      let!(:project) { FactoryGirl.create(:project) }
      let(:payload) do
        '{"name":"projectmonitor_ci_test",
        "url":"job/projectmonitor_ci_test/",
        "build":{"number":7,"phase":"FINISHED",
        "status":"FAILURE",
        "url":"job/projectmonitor_ci_test/7/"}}'
      end

      subject do
        request.env['RAW_POST_DATA'] = payload
        post :create, project_id: project.guid
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
        ProjectStatus.last.should_not be_success
        ProjectStatus.last.project_id.should == project.id
        ProjectStatus.last.build_id.should == 7
        ProjectStatus.last.published_at.should_not be_nil
      end

      it "should update parsed_url" do
        project.parsed_url.should be_nil
        subject
        project.reload.parsed_url.should include 'job/projectmonitor_ci_test/'
      end

    end

    context "TeamCity Rest project" do
      let!(:project) { FactoryGirl.create(:team_city_rest_project) }
      let(:payload) do
        '{"build" : {
          "buildStatus": "Running",
          "buildResult": "success",
          "notifyType": "buildFinished",
          "buildRunner": "Command Line",
          "buildFullName": "My Awesome Project :: RUN IT",
          "buildName": "RUN IT",
          "buildId": "13",
          "buildTypeId": "bt2",
          "projectName": "My Awesome Project",
          "projectId": "project2",
          "buildNumber": "7",
          "agentName": "Default Agent",
          "agentOs": "Mac OS X, version 10.7.4",
          "agentHostname": "localhost",
          "triggeredBy": "Dude",
          "message": "Build My Awesome Project :: RUN IT has finished. This is build number 7, has a status of \"Running\" and was triggered by Dude",
          "text": "My Awesome Project :: RUN IT has finished. Status: Running"
        }}'
      end

      subject do
        request.env['RAW_POST_DATA'] = payload
        post :create, project_id: project.guid
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
        '{"name":"projectmonitor_ci_test",
        "url":"job/projectmonitor_ci_test/",
        "build":{"number":7,"phase":"FINISHED",
        "status":"FAILURE",
        "url":"job/projectmonitor_ci_test/7/"}}'
      end

      before do
        Project.stub(:find_by_guid).and_return(project)
      end

      after do
        request.env['RAW_POST_DATA'] = payload
        post :create, project_id: project.guid
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
  end
end
