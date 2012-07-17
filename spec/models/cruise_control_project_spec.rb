require 'spec_helper'

describe CruiseControlProject do
  subject { FactoryGirl.build(:cruise_control_project) }

  describe "validations" do
    it { should validate_presence_of(:url) }

    it "should validate the URL" do
      subject.url = "example.com/proj.rss"
      should_not be_valid
      should have(1).error_on(:url)

      subject.url = "http://example.com/proj.rss"
      should be_valid

      subject.url = "https://example.com/proj.rss"
      should be_valid
    end
  end

  describe "#project_name" do
    before { subject.url = "http://example.com/baz.rss" }

    it "should return nil when url is nil" do
      subject.url = nil
      subject.project_name.should be_nil
    end

    it "should extract the project name from the RSS url" do
      subject.project_name.should == "baz"
    end

    it "should extract the project name from the RSS url regardless of capitalization" do
      subject.url = subject.url.upcase
      subject.project_name.should == "BAZ"
    end
  end
end
