shared_examples_for 'a project that updates only the most recent status' do
  describe "#process_status_update" do
    let(:project) { described_class.new.tap {|c| c.save(validate: false) } }
    let(:project_status) { double('project status') }
    let(:parsed_status) { ProjectStatus.new }
    let(:xml) { double(:xml) }

    def process_status_update
      project.process_status_update(xml)
    end

    before do
      project.stub(:status).and_return(project_status)
      project.stub(:parse_project_status).with(xml).and_return(parsed_status)
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
        expect { project.process_status_update(xml) }.to_not change(project.statuses, :count)
      end
    end
  end
end
