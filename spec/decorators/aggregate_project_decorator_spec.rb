require 'spec_helper'

describe AggregateProjectDecorator do
  let(:aggregate_project_decorator) { AggregateProjectDecorator.new(aggregate_project) }
  let(:aggregate_project) { AggregateProject.new }

  subject { aggregate_project_decorator }

  describe "#css_id" do
    let(:aggregate_project) { AggregateProject.new(id: 123) }

    its(:css_id) { should == "aggregate_project_123" }
  end

  context "the aggregate project has a failure status" do
    before { aggregate_project.stub(state: Project::State.failure) }

    its(:css_class) { should == "project failure aggregate" }
    its(:status_in_words) { should == "failure" }
  end

  context "the aggregate project has a success status" do
    before { aggregate_project.stub(state: Project::State.success) }

    its(:css_class) { should == "project success aggregate" }
    its(:status_in_words) { should == "success" }
  end

  context "the aggregate project has no statuses" do
    before { aggregate_project.stub(state: Project::State.indeterminate) }

    its(:css_class) { should == "project indeterminate aggregate" }
    its(:status_in_words) { should == "indeterminate" }
  end

  context "the aggregate project is offline" do
    before { aggregate_project.stub(state: Project::State.offline) }

    its(:css_class) { should == "project offline aggregate" }
    its(:status_in_words) { should == "offline" }
  end
end
