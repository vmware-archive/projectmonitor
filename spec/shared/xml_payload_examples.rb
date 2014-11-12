RSpec.shared_examples "a XML payload" do

  describe "project status" do
    context "when not currently building" do
      before { payload.status_content = fixture_content }

      context "when build was successful" do
        let(:fixture_file) { "success.#{fixture_ext}" }
        it { is_expected.to be_success }
      end

      context "when build had failed" do
        let(:fixture_file) { "failure.#{fixture_ext}" }
        it { is_expected.to be_failure }
      end
    end

    context "when building" do
      it "remains green when existing status is green" do
        payload.status_content = load_fixture(fixture_dir, "success.#{fixture_ext}")
        payload_processor.process_payload(project: project, payload: payload)
        statuses = project.statuses
        payload.build_status_content = build_content
        payload_processor.process_payload(project: project, payload: payload)
        expect(project).to be_success
        expect(project.statuses).to eq(statuses)
      end

      it "remains red when existing status is red" do
        payload.status_content = load_fixture(fixture_dir, "failure.#{fixture_ext}")
        payload_processor.process_payload(project: project, payload: payload)
        statuses = project.statuses
        payload.build_status_content = build_content
        payload_processor.process_payload(project: project, payload: payload)
        expect(project).to be_failure
        expect(project.statuses).to eq(statuses)
      end
    end
  end

  context "with invalid xml" do
    before(:each) { payload.status_content = "<foo><bar>baz</bar></foo>" }

    it { is_expected.not_to be_building }

    it "should not create a status" do
      expect { subject }.not_to change(ProjectStatus, :count)
    end
  end

  describe "#status_content" do
    it "should log errors from bad XML data" do
      expect(payload).to receive("log_error")
      payload.build_status_content = "some non XML content"
    end
  end

  describe "#build_status_content" do
    it "should log errors from bad XML data" do
      expect(payload).to receive("log_error")
      payload.build_status_content = "some non XML content"
    end
  end

end
