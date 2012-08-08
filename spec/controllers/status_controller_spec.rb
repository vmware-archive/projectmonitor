require 'spec_helper'
describe StatusController do
  describe "#create" do

    context "Travis project" do
      let!(:project) { FactoryGirl.create(:travis_project) }
      let(:payload) do
      '{
         "id":1885645,
         "number":"75",
         "status":1,
         "result":1,
         "status_message":"Broken",
         "result_message":"Broken",
         "started_at":"2012-07-17T14:16:37Z",
         "finished_at":"2012-07-17T14:18:52Z",
         "duration":135,
         "build_url":"http://www.google.com",
         "commit":"5bbadf792613cb64cfc67e15ae620ea3cb56b81d",
         "branch":"webhooks",
         "message":"Foo",
         "compare_url":"http://www.google.com",
         "committed_at":"2012-07-17T14:16:18Z",
         "author_name":"Foo Bar and Baz",
         "author_email":"foobar@baz.com",
         "committer_name":"Foo Bar and Baz",
         "committer_email":"foobar@baz.com"
      }'
      end

      subject { post :create, project_id: project.guid, payload: payload }

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
        ProjectStatus.last.published_at.should == Time.parse("2012-07-17T14:18:52Z")
      end
    end

    context "Jenkins project" do
      let!(:project) { FactoryGirl.create(:project) }
      let(:payload) do
        { '{"name":"projectmonitor_ci_test",
          "url":"job/projectmonitor_ci_test/",
          "build":{"number":7,"phase":"STARTED","url":"job/projectmonitor_ci_test/7/"}}' => nil }
      end

      subject { post :create, {project_id: project.guid}.merge(payload) }

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
    end

    context "TeamCity Rest project" do
      let!(:project) { FactoryGirl.create(:team_city_rest_project) }
      let(:payload) do
       {"buildStatus"=>"Running", "buildResult"=>"success", "notifyType"=>"buildFinished",
       "buildRunner"=>"Command Line",
       "buildFullName"=>"projectmonitor_ci_test_teamcity :: projectmonitor_ci_test_teamcity",
       "buildName"=>"projectmonitor_ci_test_teamcity",
       "buildId"=>"13", "buildTypeId"=>"bt2",
       "projectName"=>"projectmonitor_ci_test_teamcity",
       "projectId"=>"project2", "buildNumber"=>"13",
       "agentName"=>"Default Agent",
       "agentOs"=>"Linux, version 2.6.18-xenU-ec2-v1.5",
       "agentHostname"=>"localhost",
       "triggeredBy"=>"ci",
       "message"=>"Build projectmonitor_ci_test_teamcity :: projectmonitor_ci_test_teamcity has finished.  This is build number 13, has a status of \"Running\" and was triggered by ci",
       "text"=>"projectmonitor_ci_test_teamcity :: projectmonitor_ci_test_teamcity has finished. Status: Running"}
      end

      subject { post :create, {project_id: project.guid, "build" => payload} }

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

    end
  end
end
