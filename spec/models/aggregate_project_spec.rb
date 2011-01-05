require 'spec_helper'

describe AggregateProject do
  before :each do
    @ap = aggregate_projects(:empty_aggregate)
  end

  describe 'validations' do
    it "should be valid" do
      @ap.should be_valid
    end
  end

  describe 'associations' do
    it "should start with no projects" do
      @ap.projects.should be_empty
    end
  end

  describe 'scopes' do
    it "should return aggregate projects that contain projects" do
      AggregateProject.with_projects.should have(1).aggregate_project
      AggregateProject.with_projects.should include aggregate_projects(:internal_projects_aggregate)
      AggregateProject.with_projects.should_not include aggregate_projects(:empty_aggregate)
      AggregateProject.with_projects.should_not include aggregate_projects(:empty_aggregate)
    end
  end

  describe "acts_as_taggable" do
    it "should be able to tag an aggregate with a label" do
      @ap.tag_list.should == ["San Francisco"]
      @ap.tag_list = "A tag"
      @ap.save!
      @ap.tag_list.should == ["A tag"]
    end

    it "should be able to get all aggregate projects of a label" do
      first_tag = "A tag"
      second_tag = "A different tag"

      another_aggregate_project = aggregate_projects(:internal_projects_aggregate)
      another_aggregate_project.tag_list = first_tag
      another_aggregate_project.save!
      @ap.tag_list = first_tag
      @ap.save!
      aggregate_project_with_different_tag = aggregate_projects(:disabled)
      aggregate_project_with_different_tag.tag_list = second_tag
      aggregate_project_with_different_tag.save!

      AggregateProject.find_tagged_with(first_tag).should =~ [@ap, another_aggregate_project]
      AggregateProject.find_tagged_with(second_tag).should =~ [aggregate_project_with_different_tag]
    end
  end

  describe "#red?" do
    it "should be red if one of its projects is red" do
      @ap.should_not be_red
      @ap.projects << projects(:red_currently_building)
      @ap.should be_red
      @ap.projects << projects(:green_currently_building)
      @ap.should be_red
    end
  end

  describe "#green?" do
    it "should be green iff all projects are green" do
      @ap.should_not be_green
      @ap.projects << projects(:green_currently_building)
      @ap.should be_green
      @ap.projects << projects(:pivots)
      @ap.should be_green
    end
  end

  describe "#online?" do
    it "should not be online iff any project not online" do
      @ap.should_not be_online
      @ap.projects << projects(:socialitis)
      @ap.should be_online
      @ap.projects << projects(:pivots)
      @ap.should be_online
      @ap.projects << projects(:offline)
      @ap.should_not be_online
    end
  end

  describe '#status' do
    it "should return the last status of all the projects" do
      @ap.projects << projects(:pivots)
      @ap.projects << projects(:socialitis)
      @ap.status.should == projects(:socialitis).status
    end
  end

  describe '#building?' do
    it "should return the last status of all the projects" do
      @ap.projects << projects(:pivots)
      @ap.projects << projects(:socialitis)
      @ap.should_not be_building
      @ap.projects << projects(:green_currently_building)
      @ap.should be_building
    end
  end

  describe '#recent_online_statuses' do
    it "should return the most recent statuses across projects" do
      @ap.projects << projects(:pivots)
      @ap.projects << projects(:socialitis)
      @ap.recent_online_statuses.should include project_statuses(:pivots_status)
      @ap.recent_online_statuses.should include project_statuses(:socialitis_status_green_01)
    end
  end
end
