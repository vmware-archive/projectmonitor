require 'spec_helper'

describe Project do
  class RandomProject < Project;end

  before do
    @project = RandomProject.new(:name => "my_project", :feed_url => "http://foo.bar.com:3434/projects/mystuff/baz.rss")
  end

  it "should be valid" do
    @project.should be_valid
  end

  it "should have name as to_s" do
    @project.to_s.should == (@project.name)
  end

  describe "validation" do
    it "should require a name" do
      @project.name = ""
      @project.should_not be_valid
      @project.errors[:name].should be_present
    end

    it "should require a feed url" do
      @project.feed_url = ""
      @project.should_not be_valid
      @project.errors[:feed_url].should be_present
    end
  end

  describe 'scopes' do
    it "should return non aggregated projects" do
      Project.standalone.should include projects(:pivots)
      Project.standalone.should include projects(:socialitis)
      Project.standalone.should_not include projects(:internal_project1)
      Project.standalone.should_not include projects(:internal_project2)

    end

    it "should sort by project name" do
      sorted_projects = Project.find(:all, :conditions => {:enabled => true, :aggregate_project_id => nil}).sort_by(&:name)
      Project.standalone.should == sorted_projects
    end

  end
  describe "statuses" do
    before(:each) do
      @project = projects(:socialitis)
    end

    it "should sort by newest to oldest" do
      @project.statuses.should_not be_empty

      last_id = nil
      @project.statuses.each do |status|
        status.id.should < last_id unless last_id.nil?
        last_id = status.id
      end
    end
  end

  describe "#last green" do
    it "should return the successful project" do
      @project = projects(:socialitis)
      @project.statuses = []
      @happy_status = @project.statuses.create!(:online => true, :success => true)
      @sad_status = @project.statuses.create!(:online => true, :success => false)
      @project.last_green.should == @happy_status
    end
  end

  describe "#status" do
    before(:each) do
      @project = projects(:socialitis)
    end

    it "should return the most recent status" do
      @project.status.should == @project.statuses.find(:first)
    end

    describe "with no retrieved statuses" do
      it "should return an offline status" do
        @project.statuses.destroy_all
        @project.status.should_not be_nil
        @project.status.should_not be_online
      end
    end
  end

  describe "#aggregate_project" do
    it "should have an aggregate project, if set" do
      @project = projects(:socialitis)
      @project.aggregate_project.should be_nil
      @ap = AggregateProject.create(:name => "ap")
      @project.aggregate_project = @ap
      @project.save.should be_true
      @project = Project.find_by_name('Socialitis')
      @project.aggregate_project.should == @ap
    end
  end

  describe "#red? and #green?" do
    it "should be true/false if the project's current status is not success" do
      project = projects(:socialitis)
      project.status.success.should be_false
      project.should be_red
      project.should_not be_green
    end

    it "should be false/true if the project's current status is success" do
      project = projects(:pivots)
      project.status.success.should be_true
      project.should_not be_red
      project.should be_green
    end

    it "should be false/false if the project's current status is offline" do
      project = projects(:pivots)
      project.statuses.create!(:online => false)
      project.should_not be_green
      project.should_not be_red
    end

    it "should be false/false if the project has no statuses" do
      @project.statuses.should be_empty
      @project.should_not be_red
      @project.should_not be_green
    end
  end

  describe "#red_since" do
    it "should return #published_at for the red status after the most recent green status" do
      project = projects(:socialitis)
      red_since = project.red_since

      3.times do |i|
        project.statuses.create!(:success => false, :online => true, :published_at => Time.now + (i+1)*5.minutes )
      end

      project = Project.find(project.id)
      project.red_since.should == red_since
    end

    it "should return nil if the project is currently green" do
      project = projects(:pivots)
      project.should be_green

      project.red_since.should be_nil
    end

    it "should return the published_at of the first recorded status if the project has never been green" do
      project = projects(:never_green)
      project.statuses.detect(&:success?).should be_nil
      project.red_since.should == project.statuses.last.published_at
    end

    it "should return nil if the project has no statuses" do
      @project.statuses.should be_empty
      @project.red_since.should be_nil
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

      project = Project.find(project.id)

      # Argh.  What is the assert_approximately_equal matcher for rspec?
      # And why is the documentation for it so hard to find?
      project.red_since.to_s(:db).should == broken_at.to_s(:db)
    end
  end

  describe "#breaking build" do
    context "without any green builds" do
      it "should return the first red online build" do
        project = projects(:socialitis)
        project.statuses.destroy_all
        first_red = project.statuses.create!(:online => true, :success => false)
        project.statuses.create!(:online => true, :success => false)
        project.statuses.create!(:online => false, :success => false)
        project.breaking_build.should == first_red
      end
    end
  end

  describe "#red_build_count" do
    it "should return the number of red builds since the last green build" do
      project = projects(:socialitis)
      project.red_build_count.should == 1

      project.statuses.create(:online => true, :success => false)
      project.red_build_count.should == 2
    end

    it "should return zero for a green project" do
      project = projects(:pivots)
      project.should be_green

      project.red_build_count.should == 0
    end

    it "should not blow up for a project that has never been green" do
      project = projects(:never_green)
      project.red_build_count.should == project.statuses.count
    end

    it "should return zero for an offline project" do
      project = projects(:offline)
      project.should_not be_online

      project.red_build_count.should == 0
    end

    it "should ignore offline statuses" do
      project = projects(:never_green)
      old_red_build_count = project.red_build_count

      3.times do
        project.statuses.create(:online => false)
      end
      project.statuses.create(:online => true, :success => false)
      project.red_build_count.should == old_red_build_count + 1
    end
  end

  describe "#enabled" do
    it "should be enabled by default" do
      project = Project.new
      project.should be_enabled
    end

    it "should store enabledness" do
      projects(:pivots).should be_enabled
      projects(:disabled).should_not be_enabled
    end
  end

  describe "#building?" do
    it "should be true if the project is currently building" do
      projects(:red_currently_building).should be_building
    end

    it "should return false for a project that is not currently building" do
      projects(:many_builds).should_not be_building
    end

    it "should return false for a project that has never been built" do
      projects(:never_built).should_not be_building
    end
  end

  describe "#build_status_url" do
    it "should use the host name from the RSS URL, including the port" do
      @project.build_status_url.should =~ /^#{Regexp.escape("http://foo.bar.com:3434")}/
    end

    it "should end with the appropriate location" do
      @project.build_status_url.should =~ /#{Regexp.escape("XmlStatusReport.aspx")}$/
    end

    it "should not blow up if the RSS URL is not set (and the project is therefore invalid)" do
      @project.feed_url = nil
      @project.build_status_url.should be_nil
    end
  end

  describe "#project_name" do
    it "should return nil when feed_url is nil" do
      @project.feed_url = nil
      @project.project_name.should be_nil
    end

    it "should just use the feed URL" do
      @project.project_name.should == @project.feed_url
    end
  end

  describe "#needs_poll?" do
    it "should return true if current time >= next_poll_at" do
      @project.next_poll_at = 5.minutes.ago
      @project.needs_poll?.should be_true
    end

    it "should return false when current time < next_poll_at" do
      @project.next_poll_at = 5.minutes.from_now
      @project.needs_poll?.should be_false
    end

    it "should return true if next_poll_at is null" do
      @project.needs_poll?.should be_true
    end
  end

  describe "#set_next_poll!" do
    epsilon = 2
    context "with a project poll interval set" do
      before do
        @project.polling_interval = 25
      end

      it "should set the next_poll_at to Time.now + the project poll interval" do
        @project.set_next_poll!
        (@project.reload.next_poll_at - (Time.now + @project.polling_interval)).abs.should <= epsilon
      end
    end

    context "without a project poll interval set" do
      it "should set the next_poll_at to Time.now + the system default interval" do
        @project.set_next_poll!
        (@project.reload.next_poll_at - (Time.now + Project::DEFAULT_POLLING_INTERVAL)).abs.should <= epsilon
      end
    end
  end

  describe "#has_auth?" do
    it "returns true if either username or password exists" do
      @project.auth_username = "uname"
      @project.has_auth?.should be_true

      @project.auth_username = nil
      @project.auth_password = "pwd"
      @project.has_auth?.should be_true
    end

    it "returns false if both username and password are blank" do
      @project.auth_username = ""
      @project.auth_password = nil
      @project.has_auth?.should be_false
    end
  end
end
