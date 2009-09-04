require File.dirname(__FILE__) + '/../spec_helper'

describe Project do
  before(:each) do
    @project = Project.new(:name => "my_project", :cc_rss_url => "http://foo.bar.com:3434/projects/mystuff/baz.rss")
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
      @project.errors[:name].should_not be_nil
    end

    it "should require an RSS URL" do
      @project.cc_rss_url = ""
      @project.should_not be_valid
      @project.errors[:cc_rss_url].should_not be_nil
    end

    it "should require that the RSS URL contain a valid domain" do
      @project.cc_rss_url = "foo"
      @project.should_not be_valid
      @project.errors[:cc_rss_url].should_not be_nil
    end

    it "should require that the RSS URL contain a valid address" do
      @project.cc_rss_url = "http://foo.bar.com/"
      @project.should_not be_valid
      @project.errors[:cc_rss_url].should_not be_nil
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

  describe "#recent_online_statuses" do
    it "should should return 'count' recent online statuses" do
      project = projects(:socialitis)
      project.statuses.delete_all
      online_status = project.statuses.create!(:success => false, :online => true)
      offline_status = project.statuses.create!(:success => false, :online => false)
      
      project.recent_online_statuses.should include(online_status)
      project.recent_online_statuses.should_not include(offline_status)
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

      broken_at = Time.now
      3.times do
        project.statuses.create!(:online => false)
        broken_at += 5.minutes
      end

      project.statuses.create!(:online => true, :success => false, :published_at => broken_at)

      project = Project.find(project.id)

      # Argh.  What is the assert_approximately_equal matcher for rspec?
      # And why is the documentation for it so hard to find?
      project.red_since.to_s.should == broken_at.to_s
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
      @project.cc_rss_url = nil
      @project.build_status_url.should be_nil
    end
  end
  
  describe "#cc_project_name" do
    it "should return nil when cc_rss_url is nil" do
      @project.cc_rss_url = nil
      @project.cc_project_name.should be_nil
    end

    it "should extract the project name from the RSS url" do
      @project.cc_project_name.should == "baz"
    end

    it "should extract the project name from the RSS url regardless of capitalization" do
      @project.cc_rss_url = @project.cc_rss_url.upcase
      @project.cc_project_name.should == "BAZ"
    end
  end
end
