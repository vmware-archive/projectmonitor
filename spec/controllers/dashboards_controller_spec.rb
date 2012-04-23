require 'spec_helper'

describe DashboardsController do
  let(:project) { FactoryGirl.build(:project) }
  let(:aggregate_project) { FactoryGirl.build(:aggregate_project) }

  describe "#feed" do
    before do
      Project.stub_chain(:standalone, :with_statuses).and_return [project]
      AggregateProject.stub_chain(:with_statuses).and_return [aggregate_project]
      get :builds, :format => "rss"
    end

    it "renders an RSS feed" do
      response.should render_template("builds")
    end

    it "assigns all projects and aggregate projects" do
      assigns(:projects).should =~ [project, aggregate_project]
    end
  end

  describe "#index" do
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

      [15, 24, 48].each do |tiles_count|
        context "#{tiles_count} tiles" do
          it "displays #{tiles_count}" do
            get :index, tiles_count: tiles_count
            assigns(:projects).size.should == tiles_count
          end
        end
      end
    end

    context "with multiple projects" do
      let(:projects) { assigns(:projects).compact }

      before do
        Project.delete_all
        AggregateProject.delete_all

        FactoryGirl.create(:project, :name => "AA")
        FactoryGirl.create(:project, :name => "CA")
        FactoryGirl.create(:project, :name => "ba")
        AggregateProject.create!(:name => "AB")
        AggregateProject.create!(:name => "CB")
        AggregateProject.create!(:name => "bb")

        get :index
      end

      it "sorts the projects in alphabetical order, case-insensitively" do
        projects.map(&:name).should == ["AA", "AB", "ba", "bb", "CA", "CB"]
      end
    end
  end
end
