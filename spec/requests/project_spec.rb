require "spec_helper"

describe "Project", :type => :request do
  describe "/validate_build_info" do
    it "returns log entry" do
      project = create(:project, ci_build_identifier: 'twitter-for-dogs')
      stub_jenkins!

      VCR.turned_off { patch "/projects/validate_build_info", project: project.attributes.merge(auth_password: "password") }
      expect(response.body).to include "Error converting content"
    end
  end

  describe "/validate_tracker_project" do
    it "returns validation status" do
      project = create(:project)

      post "/projects/validate_tracker_project", { id: project.id, auth_token: 'token', project_id: project.id }
      expect(response.status).to be(202)
    end
  end
end

def stub_jenkins!
  stub_request(:get, "http://www.example.com/job/twitter-for-dogs/rssAll").to_return(body: File.new('spec/fixtures/jenkins_atom_examples/invalid_xml.atom'))
  stub_request(:get, "http://www.example.com/cc.xml").to_return(body: File.new('spec/fixtures/jenkins_atom_examples/invalid_xml.atom'))
end
