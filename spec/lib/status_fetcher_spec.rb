require 'spec_helper'

describe StatusFetcher::Job do

  describe "#perform" do
    let(:project) { double(:project) }

    before do
      StatusFetcher.should_receive(:retrieve_status_for).with project
      StatusFetcher.should_receive(:retrieve_building_status_for).with project
      project.should_receive(:set_next_poll!).and_return true
    end

    subject { StatusFetcher::Job.new(project).perform }

    it { should be_true }
  end

end

describe StatusFetcher do
  let(:project) { Project.new }

  describe "#fetch_all" do
    let(:projects) { [project] }

    before do
      Project.stub(:all).and_return projects
      project.stub(:needs_poll?).and_return true
    end

    subject { StatusFetcher.fetch_all }

    context "some projects don't need to be polled" do
      let(:non_polling_project) { Project.new }
      let(:job) { double(:delayed_job) }
      let(:projects) { [project, non_polling_project] }

      before do
        non_polling_project.stub(:needs_poll?).and_return false
        StatusFetcher::Job.should_receive(:new).with(project).and_return job
        Delayed::Job.should_receive(:enqueue).with job
      end

      it { should == [project] }
    end
  end

  describe "#retrieve_status_for" do
    let(:content) { double(:xml_content) }
    let(:status)  { ProjectStatus.new }

    subject { StatusFetcher.retrieve_status_for project }

    context "project status can be retrieved from remote source" do
      before do
        UrlRetriever.stub(:retrieve_content_at).and_return content
        project.should_receive(:parse_project_status).with(content).and_return status
        project.stub_chain(:statuses, :create).and_return "success"
      end

      context "a matching status does not exist" do
        before do
          project.stub_chain(:status, :match?).with(status).and_return(false)
        end

        it { should == "success" }
      end

      context "a matching status exists" do
        before do
          project.stub_chain(:status, :match?).with(status).and_return(true)
        end

        it { should be_nil }
      end

    end

    context "project status can not be retrieved" do
      before do
        UrlRetriever.stub(:retrieve_content_at).and_raise Net::HTTPError.new("can't do it", 500)
        project.stub_chain(:statuses, :create).and_return "success"
      end

      context "a status does not exist with that error" do
        before do
          project.stub(:status).and_return status
          status.stub(:error).and_return "another error"
        end

        it { should == "success" }
      end

      context "a status exists with that error" do
        before do
          project.stub(:status).and_return status
          status.stub(:error).and_return "HTTP Error retrieving status for project '##{project.id}': can't do it"
        end

        it { should be_nil }
      end
    end

  end

  describe "#retrieve_building_status_for" do
    let(:content) { double(:content) }
    let(:building_status) { [true, false].sample }
    let(:status) { double(:status, :building? => building_status )}

    subject do
      project.building
    end

    context "project status can be retrieved from the remote source" do
      before do
        UrlRetriever.stub(:retrieve_content_at).and_return content
        project.should_receive(:parse_building_status).with(content).and_return status
        StatusFetcher.retrieve_building_status_for project
      end

      it { should == building_status }
    end

    context "project status can not be retrieved" do
      before do
        UrlRetriever.stub(:retrieve_content_at).and_raise Net::HTTPError.new("can't do it", 500)
        StatusFetcher.retrieve_building_status_for project
      end

      it { should be_false }
    end

  end

end
