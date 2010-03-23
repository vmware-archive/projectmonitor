require File.dirname(__FILE__) + '/../spec_helper'

describe Project do
  before(:each) do
    @project = CruiseControlProject.new(:name => "my_cc_project", :feed_url => "http://foo.bar.com:3434/projects/mystuff/baz.rss")
  end

  describe "validations" do
    describe "validation" do
      it "should require an RSS URL" do
        @project.feed_url = ""
        @project.should_not be_valid
        @project.errors[:feed_url].should_not be_nil
      end

      it "should require that the RSS URL contain a valid domain" do
        @project.feed_url = "foo"
        @project.should_not be_valid
        @project.errors[:feed_url].should_not be_nil
      end

      it "should require that the RSS URL contain a valid address" do
        @project.feed_url = "http://foo.bar.com/"
        @project.should_not be_valid
        @project.errors[:feed_url].should_not be_nil
      end
    end
  end
  
  describe "#project_name" do
    it "should return nil when feed_url is nil" do
      @project.feed_url = nil
      @project.project_name.should be_nil
    end

    it "should extract the project name from the RSS url" do
      @project.project_name.should == "baz"
    end

    it "should extract the project name from the RSS url regardless of capitalization" do
      @project.feed_url = @project.feed_url.upcase
      @project.project_name.should == "BAZ"
    end
  end
end
