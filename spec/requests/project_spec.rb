require "spec_helper"

describe "Project" do
  describe "/validate_build_info" do
    it "returns log entry" do
      project = FactoryGirl.create(:project)
      ProjectUpdater.stub(:update).and_return(PayloadLogEntry.new(error_text: "Build unsuccessful"))

      post "/projects/validate_build_info", project: project.attributes.merge(auth_password: "password")
      expect(response.body).to match /Build unsuccessful/
    end
  end

  describe "/validate_tracker_project" do
    it "returns validation status" do
      project = FactoryGirl.create(:project)

      post "/projects/validate_tracker_project", { id: project.id, auth_token: 'token', project_id: project.id }
      expect(response.status).to be(202)
    end
  end
end
