require "spec_helper"

describe "Project" do
  describe "/validate_build_info" do
    it "returns log entry" do
      project = FactoryGirl.create(:project, jenkins_build_name: 'twitter-for-dogs')
      fake_jenkins!

      patch "/projects/validate_build_info", project: project.attributes.merge(auth_password: "password")
      expect(response.body).to match /Error parsing content for build name twitter-for-dogs/
    end
  end

  describe "/validate_tracker_project" do
    it "returns validation status" do
      project = FactoryGirl.create(:project)

      post "/projects/validate_tracker_project", { id: project.id, auth_token: 'token', project_id: project.id }
      expect(response.status).to be(202)
    end
  end

  def fake_jenkins!
    FakeWeb.register_uri(:get, "http://www.example.com/job/twitter-for-dogs/rssAll", body: File.new('spec/fixtures/jenkins_atom_examples/invalid_xml.atom'))
    FakeWeb.register_uri(:get, "http://www.example.com/cc.xml", body: File.new('spec/fixtures/jenkins_atom_examples/invalid_xml.atom'))
  end
end
