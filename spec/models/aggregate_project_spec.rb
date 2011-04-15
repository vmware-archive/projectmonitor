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
    it "should not be online if any project not online" do
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

  describe "#red_since" do
    class RandomProject < Project;end;

    it "should return #published_at for the red status after the most recent green status" do
      socialitis = projects(:socialitis)
      red_since = socialitis.red_since

      3.times do |i|
        socialitis.statuses.create!(:success => false, :online => true, :published_at => Time.now + (i+1)*5.minutes )
      end

      @ap.projects << socialitis

      @ap = AggregateProject.find(@ap.id)
      @ap.red_since.should == red_since
    end

    it "should return nil if the project is currently green" do
      pivots = projects(:pivots)
      @ap.projects << pivots
      pivots.should be_green

      pivots.red_since.should be_nil
    end

    it "should return the published_at of the first recorded status if the project has never been green" do
      project = projects(:never_green)
      @ap.projects << project
      @ap.statuses.detect(&:success?).should be_nil
      @ap.red_since.should == project.statuses.last.published_at
    end

    it "should return nil if the project has no statuses" do
      @project = RandomProject.new(:name => "my_project_foo", :feed_url => "http://foo.bar.com:3434/projects/mystuff/baz.rss")
      @ap.projects << @project
      @ap.red_since.should be_nil
    end

    it "should ignore offline statuses" do
      project = projects(:pivots)
      project.should be_green

      broken_at = Time.now.utc
      3.times do
        project.statuses.create!(:online => false)
        broken_at += 5.minutes
      end

      project.statuses.create!(:online => true, :success => false, :published_at => broken_at)

      @ap.projects << project

      ap = AggregateProject.find(@ap.id)

      ap.red_since.to_s(:db).should == broken_at.to_s(:db)
    end
  end

  describe "#red_build_count" do
    it "should return the number of red builds since the last green build" do
      project = projects(:socialitis)
      @ap.projects << project
      @ap.red_build_count.should == 1

      project.statuses.create(:online => true, :success => false)
      @ap.red_build_count.should == 2
    end

    it "should return zero for a green project" do
      project = projects(:pivots)
      @ap.projects << project
      @ap.should be_green

      @ap.red_build_count.should == 0
    end

    it "should not blow up for a project that has never been green" do
      project = projects(:never_green)
      @ap.projects << project
      @ap.red_build_count.should == @ap.statuses.count
    end

    it "should return zero for an offline project" do
      project = projects(:offline)
      @ap.projects << project
      @ap.should_not be_online

      @ap.red_build_count.should == 0
    end

    it "should ignore offline statuses" do
      project = projects(:never_green)
      @ap.projects << project
      old_red_build_count = @ap.red_build_count

      3.times do
        project.statuses.create(:online => false)
      end
      project.statuses.create(:online => true, :success => false)
      @ap.red_build_count.should == old_red_build_count + 1
    end
  end

  describe "#breaking_build" do
    context "when a project does not have a published_at date" do
      it "should be ignored" do
        project = projects(:red_currently_building)
        other_project = projects(:socialitis)

        project.statuses.create(:online => true, :success => true, :published_at => 1.day.ago)
        status = project.statuses.create(:online => true, :success => false, :published_at => Time.now)

        other_project.statuses.create(:online => true, :success => true, :published_at => 1.day.ago)
        bad_status = other_project.statuses.create(:online => true, :success => false, :published_at => nil)
        @ap.projects << project
        @ap.projects << other_project
        @ap.breaking_build.should == status
      end
    end
  end

end
