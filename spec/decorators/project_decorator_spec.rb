require 'spec_helper'

describe ProjectDecorator do
  describe "#css_id" do
    let(:id) { "123" }
    subject { ProjectDecorator.new(project).css_id }

    before { project.stub(id: id)}

    context "when Project" do
      let(:project) { CruiseControlProject.new }

      it { should == "project_#{id}"}
    end

    context "when AggregateProject" do
      let(:project) { AggregateProject.new }

      it { should == "aggregate_project_#{id}"}
    end

  end

  describe "#css_class" do
    subject { ProjectDecorator.new(project).css_class }
    let(:project) { double :project, red?: red, green?: green, yellow?: yellow }
    let(:red) { false }
    let(:green) { false }
    let(:yellow) { false }

    context "project is red" do
      let(:red) { true }
      it { should == "project failure"}
    end

    context "project is green" do
      let(:green) { true }
      it { should == "project success"}
    end

    context "project is yellow" do
      let(:yellow) { true }
      it { should == "project indeterminate"}
    end

    context "project is offline" do
      it { should == "project offline"}
    end

    context "project is aggregate" do
      before do
        project.stub :projects
      end

      it { should include "aggregate"}
    end
  end
end
