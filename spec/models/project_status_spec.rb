require File.expand_path(File.join(File.dirname(__FILE__),'..','spec_helper'))
require 'xml/libxml'

describe ProjectStatus do
  before(:each) do
    @project_status = ProjectStatus.new
  end

  it "should default to not online" do
    @project_status.should_not be_online
  end
  
  describe "in_words" do
    it "returns success for a successful status" do
      status = project_statuses(:socialitis_status_green_01)
      status.in_words.should == 'success'
    end
    it "returns offline for an offline status" do
      status = project_statuses(:offline_status)
      status.in_words.should == 'offline'
    end

    it "returns failure for a failed status" do
      status = project_statuses(:socialitis_status_old_red_00)
      status.in_words.should == 'failure'
    end

  end

  describe "#match?" do
    describe "for an offline status" do
      it "should return true for a hash with :online => false" do
        @project_status.match?(:online => false).should be_true
      end

      it "should return false for a hash with :online => true" do
        @project_status.match?(:online => true).should be_false
      end
    end

    describe "for an online status" do
      before(:each) do
        @success = true
        @url = "http://foo/bar.rss"
        @published_at = Time.now

        @project_status.attributes = online_status_hash
      end

      it "should return false for a hash with :online => false" do
        @project_status.match?(online_status_hash(:online => false)).should be_false
      end

      it "should return true for a hash that with the same value as self for success, published_at, and url" do
        @project_status.match?(online_status_hash).should be_true
      end

      it "should return false for a hash with a different value for success" do
        (different_success = false).should_not == @success
        @project_status.match?(online_status_hash.merge(:success => different_success)).should be_false
      end

      it "should return false for a hash with a different value for published_at" do
        (different_published_at = Time.now - 10.minutes).should_not == @published_at
        @project_status.match?(online_status_hash.merge(:published_at => different_published_at)).should be_false
      end

      it "should return false for a hash with a different value for url" do
        (different_url = "http://your/mother.rss").should_not == @url
        @project_status.match?(online_status_hash.merge(:url => different_url)).should be_false
      end

      private

      def online_status_hash(options = {})
        {
          :online => true,
          :success => @success,
          :url => @url,
          :published_at => @published_at
        }.merge(options)
      end
    end
  end
end
