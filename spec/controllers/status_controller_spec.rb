require 'spec_helper'
describe StatusController do
  let!(:project) { TravisProject.create!(name: "foo", feed_url: "http://travis-ci.org/account/project/builds.json") }
  let(:payload) {
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
  }
  describe "#create" do
    subject { post :create, project_id: project.id, payload: payload }

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
end
