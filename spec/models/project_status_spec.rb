require 'spec_helper'

describe ProjectStatus do
  before do
    @project_status = ProjectStatus.new
  end

  describe 'scopes' do
    describe "#recent" do
      it "finds statuses with a published_at date" do
        project = projects(:socialitis)
        project.statuses.delete_all
        status = project.statuses.create!(:success => false, :published_at => 1.day.ago)
        status_without_published_at = project.statuses.create!(:success => false, :published_at => nil)

        ProjectStatus.recent(project, 3).should include(status)
        ProjectStatus.recent(project, 3).should_not include(status_without_published_at)
      end

      it "finds statuses across multiple projects" do
        socialitis = projects(:socialitis)
        socialitis.statuses.delete_all
        socialitis_status = socialitis.statuses.create!(:success => false, :published_at => 1.day.ago)
        pivots = projects(:pivots)
        pivots.statuses.delete_all
        pivots_status = pivots.statuses.create!(:success => false, :published_at => 1.day.ago)

        results = ProjectStatus.recent([socialitis, pivots], 3)
        results.should include(socialitis_status, pivots_status)
      end

      it "finds statuses ordered by published_at date" do
        socialitis = projects(:socialitis)
        socialitis.statuses.delete_all
        socialitis_status = socialitis.statuses.create!(:success => false, :published_at => 10.days.ago)
        pivots = projects(:pivots)
        pivots.statuses.delete_all
        pivots_status1 = pivots.statuses.create!(:success => false, :published_at => 20.days.ago)
        pivots_status2 = pivots.statuses.create!(:success => false, :published_at => 5.days.ago)

        results = ProjectStatus.recent([socialitis, pivots], 3)
        results.should == [pivots_status2, socialitis_status, pivots_status1]
      end
    end
  end

  describe "after_create" do
    it "becomes project's latest_status" do
      project = projects(:pivots)
      status = project.statuses.create(published_at: Time.now)
      project.reload.latest_status.should == status
    end
  end

  describe "in_words" do
    it "returns success for a successful status" do
      status = project_statuses(:socialitis_status_green_01)
      status.in_words.should == 'success'
    end

    it "returns failure for a failed status" do
      status = project_statuses(:socialitis_status_old_red_00)
      status.in_words.should == 'failure'
    end
  end

  describe "#match?" do
    it "should return true for a hash that with the same value as self for success, published_at, and url" do
      ProjectStatus.new(status_hash).match?(ProjectStatus.new(status_hash)).should be_true
    end

    it "should return false for a hash with a different value for success" do
      ProjectStatus.new(status_hash).match?(ProjectStatus.new(:success => false)).should be_false
    end

    it "should return false for a hash with a different value for published_at" do
      different_published_at = Time.now - 10.minutes
      ProjectStatus.new(status_hash).match?(ProjectStatus.new(:published_at => different_published_at)).should be_false
    end

    it "should return false for a hash with a different value for url" do
      different_url = "http://your/mother.rss"
      ProjectStatus.new(status_hash).match?(ProjectStatus.new(:url => different_url)).should be_false
    end

    private

    def status_hash(options = {})
      {
        :success => true,
        :url => "http://foo/bar.rss",
        :published_at => Time.utc(2007, 1, 4)
      }.merge(options)
    end
  end
end
