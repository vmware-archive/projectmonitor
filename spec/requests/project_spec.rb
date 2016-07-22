require "spec_helper"

describe "Project", :type => :request do
  describe "/validate_build_info" do
    let!(:project) { create(:project, ci_build_identifier: 'twitter-for-dogs') }

    around do |example|
      stub_request(:get, "http://www.example.com/job/twitter-for-dogs/rssAll")
        .to_return(body: File.new('spec/fixtures/jenkins_atom_examples/invalid_xml.atom'))
      stub_request(:get, "http://www.example.com/cc.xml")
        .to_return(body: File.new('spec/fixtures/jenkins_atom_examples/invalid_xml.atom'))

      VCR.turned_off { example.run }
    end

    it "returns log entry" do
      patch "/projects/validate_build_info", params: { project: project.attributes.merge(auth_password: "password") }
      expect(response.body).to include "Error converting content"
    end

    it "does not duplicate projects when validating a persisted project" do
      expect {
        patch "/projects/validate_build_info", params: { project: project.attributes.merge(auth_password: "password") }
      }.not_to change { Project.count }
    end

    it "does not create a project when validating an unpersisted project" do
      expect {
        patch "/projects/validate_build_info", params: { project: project.attributes.except('id').merge(auth_password: "password") }
      }.not_to change { Project.count }
    end
  end

  describe "/validate_tracker_project" do
    it "returns validation status" do
      project = create(:project)

      post "/projects/validate_tracker_project", params: { id: project.id, auth_token: 'token', project_id: project.id }
      expect(response.status).to be(202)
    end
  end
end
