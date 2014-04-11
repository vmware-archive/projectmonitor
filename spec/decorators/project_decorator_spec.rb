require 'spec_helper'

describe ProjectDecorator do
  let(:project_decorator) { ProjectDecorator.new(project) }
  let(:project) { Project.new }

  subject { project_decorator }

  describe "#css_id" do
    context "when Project" do
      let(:project) { Project.new(id: 123) }

      its(:css_id) { should == "project_123" }
    end
  end

  describe "#current_build_url" do
    its(:current_build_url) { should be_nil }
  end

  context "the project has a failure status" do
    before { project.stub(state: Project::State.failure) }

    its(:css_class) { should == "project failure" }
    its(:status_in_words) { should == "failure" }
  end

  context "the project has a success status" do
    before { project.stub(state: Project::State.success) }

    its(:css_class) { should == "project success" }
    its(:status_in_words) { should == "success" }
  end

  context "the project has no statuses" do
    before { project.stub(state: Project::State.indeterminate) }

    its(:css_class) { should == "project indeterminate" }
    its(:status_in_words) { should == "indeterminate" }
  end

  context "the project is offline" do
    before { project.stub(state: Project::State.offline) }

    its(:css_class) { should == "project offline" }
    its(:status_in_words) { should == "offline" }
  end
end
