require 'spec_helper'

describe DashboardGrid do
  let(:project) { Project.new }
  let(:aggregate_project) { AggregateProject.new }

  context "no tags" do
    before do
      Project.should_receive(:standalone).and_return [project]
      AggregateProject.should_receive(:all).and_return [aggregate_project]
    end

    it "assigns all projects and aggregate projects" do
      projects = DashboardGrid.generate
      projects.should include(project)
      projects.should include(aggregate_project)
    end
  end

  context "tags" do
    before do
      Project.should_receive(:standalone_with_tags).with("foo,bar").and_return [project]
      AggregateProject.should_receive(:all_with_tags).with("foo,bar").and_return [aggregate_project]
    end

    it "assigns all projects and aggregate projects with the requested tags" do
      projects = DashboardGrid.generate(tags: "foo,bar")
      projects.should include(project)
      projects.should include(aggregate_project)
    end
  end

  context "tiles_count" do
    it "displays 15 when no params present" do
      projects = DashboardGrid.generate
      projects.size.should == 15
    end

    [15, 24, 48, 63].each do |tiles_count|
      context "#{tiles_count} tiles" do
        it "displays #{tiles_count}" do
          projects = DashboardGrid.generate(tiles_count: tiles_count)
          projects.size.should == tiles_count
        end
      end
    end
  end

  context "view" do
    context "locations" do
      it "displays projects under the appropriate location" do
        Project.destroy_all
        AggregateProject.destroy_all

        FactoryGirl.create(:project, name: "Other 1")
        FactoryGirl.create(:project, name: "Other 2")
        FactoryGirl.create(:project, location: "Boston", name: "Boston 1")
        FactoryGirl.create(:project, location: "Boston", name: "Boston 2")
        FactoryGirl.create(:project, location: "Boston", name: "Boston 3")
        FactoryGirl.create(:project, location: "San Francisco", name: "San Francisco 1")
        FactoryGirl.create(:project, location: "Atlanta", name: "Atlanta 1")
        FactoryGirl.create(:project, location: "Atlanta", name: "Atlanta 2")

        projects = DashboardGrid.generate(view: "locations")

        projects.select { |p| p.is_a?(Location) }.count.should == 4
        projects.select { |p| p.is_a?(Project) }.count.should == 8
        projects.select { |p| p.nil? }.count.should == 51
        projects.count.should == 63

        projects.map(&:to_s).should == [
          "San Francisco",   "Atlanta",   "Boston",   "Other",   "", "", "",
          "San Francisco 1", "Atlanta 1", "Boston 1", "Other 1", "", "", "",
          "",                "Atlanta 2", "Boston 2", "Other 2", "", "", "",
          "",                "",          "Boston 3", "",        "", "", "",
          "",                "",          "",         "",        "", "", "",
          "",                "",          "",         "",        "", "", "",
          "",                "",          "",         "",        "", "", "",
          "",                "",          "",         "",        "", "", "",
          "",                "",          "",         "",        "", "", ""
        ]
      end
    end
  end

  context "with multiple projects" do
    fixtures :projects, :aggregate_projects

    let(:projects) { DashboardGrid.generate.compact }

    before do
      projects.size.should > 1
    end

    it "sorts the projects in alphabetical order" do
      projects.should == projects.sort_by(&:name)
    end
  end
end
