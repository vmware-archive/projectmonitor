shared_examples_for 'a project that updates only the most recent status' do
  describe "#process_status_update" do
    let(:project) { described_class.new.tap {|c| c.save(validate: false) } }
    let(:project_status) { double('project status') }
    let(:parsed_status) { ProjectStatus.new }

    def process_status_update
      project.process_status_update
    end

    before do
      project.stub(:status).and_return(project_status)
      project.stub(:parse_project_status).and_return(parsed_status)
    end

    context "project status can not be retrieved from remote source" do
      before do
        UrlRetriever.stub(:retrieve_content_at).and_raise Net::HTTPError.new("can't do it", 500)
        project.stub(:status).and_return project_status
        project.stub(:statuses).and_return(double('statuses'))
      end

      context "a status does not exist with the error that is returned" do
        before do
          project_status.stub(:error).and_return "another error"
        end

        it "creates a status with the error message" do
          project.statuses.should_receive(:create)
          process_status_update
        end
      end

      context "a status exists with the error that is returned" do
        before do
          project_status.stub(:error).and_return "HTTP Error retrieving status for project '##{project.id}': can't do it"
        end

        it "does not create a duplicate status" do
          project.statuses.should_not_receive(:create)
          process_status_update
        end
      end
    end


    context "project status can be retrieved" do
      before do
        UrlRetriever.stub(:retrieve_content_at).and_return "<something />"
      end

      context "when the parsed status is new" do
        before do
          project_status.stub(:match?).and_return(false)
        end

        it "creates a new status for the project" do
          expect { process_status_update }.to change(project.statuses, :count).by(1)
        end

        it "creates an online status" do
          process_status_update
          project.statuses.first.should be_online
        end
      end

      context "when the parsed status already exists" do
        before do
          project_status.stub(:match?).and_return(true)
        end

        it "does not create a new status for the project" do
          expect { process_status_update }.to_not change(project.statuses, :count)
        end
      end
    end
  end
end
