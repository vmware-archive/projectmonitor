require 'spec_helper'

describe DashboardsController do
  describe "#index" do
    let(:project) { double(:project) }
    let(:aggregate_project) { double(:aggregate_project) }

    context "no tags" do
      before do
        Project.should_receive(:standalone).and_return [project]
        AggregateProject.should_receive(:all).and_return [aggregate_project]
        get :index
      end

      it "assigns all projects and aggregate projects" do
        assigns(:projects).should include(project)
        assigns(:projects).should include(aggregate_project)
      end
    end

    context "tags" do
      before do
        Project.should_receive(:standalone_with_tags).with("foo,bar").and_return [project]
        AggregateProject.should_receive(:all_with_tags).with("foo,bar").and_return [aggregate_project]
        get :index, tags: "foo,bar"
      end

      it "assigns all projects and aggregate projects with the requested tags" do
        assigns(:projects).should include(project)
        assigns(:projects).should include(aggregate_project)
      end
    end

    context "tiles_count" do
      it "displays 15 when no params present" do
        get :index
        assigns(:projects).size.should == 15
      end

      [15, 24].each do |tiles_count|
        context "#{tiles_count} tiles" do
          it "displays #{tiles_count}" do
            get :index, tiles_count: tiles_count
            assigns(:projects).size.should == tiles_count
          end
        end
      end
    end
  end
end
