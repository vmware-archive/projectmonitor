require 'spec_helper'

describe CruiseControlProject do
  subject { FactoryGirl.build(:cruise_control_project) }

  describe 'factories' do
    subject { FactoryGirl.build(:cruise_control_project) }
    it { should be_valid }
  end

  describe "validations" do
    context "when webhooks are enabled" do
      subject { Project.new(webhooks_enabled: true)}
      it { should_not validate_presence_of(:cruise_control_rss_feed_url) }
    end

    context "when webhooks are not enabled" do
      it { should validate_presence_of(:cruise_control_rss_feed_url) }

      it do
        should allow_value("http://example.com/proj.rss",
                           "https://example.com/proj.rss",
                           "HTTP://example.com/proj.rss").for(:cruise_control_rss_feed_url)
      end

      it do
        should_not allow_value("ttp://example.com/proj.rss",
                               "sql injection\nhttps://example.com/proj.rss").for(:cruise_control_rss_feed_url)

      end
    end
  end

  its(:feed_url) { should == "http://www.example.com/project.rss" }

  describe "#build_status_url" do
    let(:project) { FactoryGirl.build(:cruise_control_project) }
    subject { project.build_status_url }

    it { should match %r{\Ahttp://www.example.com:80} }
    it { should include 'XmlStatusReport.aspx' }

    it "should not blow up if the RSS URL is not set (and the project is therefore invalid)" do
      project.cruise_control_rss_feed_url = nil
      subject.should be_nil
    end
  end

  describe "#project_name" do
    it "should return nil when url is nil" do
      subject.cruise_control_rss_feed_url = nil
      subject.project_name.should be_nil
    end

    it "should extract the project name from the RSS url" do
      subject.cruise_control_rss_feed_url = "http://example.com/baz.rss"
      subject.project_name.should == "baz"
    end

    it "should extract the project name from the RSS url regardless of capitalization" do
      subject.cruise_control_rss_feed_url = "HTTP://EXAMPLE.COM/BAZ.RSS"
      subject.project_name.should == "BAZ"
    end
  end

end
