require 'spec_helper'

describe CruiseControlProject, :type => :model do
  subject { build(:cruise_control_project) }

  describe "validations" do
    context "when webhooks are enabled" do
      subject { Project.new(webhooks_enabled: true)}
      it { is_expected.not_to validate_presence_of(:cruise_control_rss_feed_url) }
    end

    context "when webhooks are not enabled" do
      it { is_expected.to validate_presence_of(:cruise_control_rss_feed_url) }

      it do
        is_expected.to allow_value("http://example.com/proj.rss",
                           "https://example.com/proj.rss",
                           "HTTP://example.com/proj.rss").for(:cruise_control_rss_feed_url)
      end

      it do
        is_expected.not_to allow_value("ttp://example.com/proj.rss",
                               "sql injection\nhttps://example.com/proj.rss").for(:cruise_control_rss_feed_url)

      end
    end
  end

  describe '#feed_url' do
    it { expect(subject.feed_url).to eq("http://www.example.com/project.rss") }
  end

  describe "#build_status_url" do
    let(:project) { build(:cruise_control_project) }
    subject { project.build_status_url }

    it { is_expected.to match %r{\Ahttp://www.example.com:80} }
    it { is_expected.to include 'XmlStatusReport.aspx' }

    it "should not blow up if the RSS URL is not set (and the project is therefore invalid)" do
      project.cruise_control_rss_feed_url = nil
      expect(subject).to be_nil
    end
  end

  describe "#project_name" do
    it "should return nil when url is nil" do
      subject.cruise_control_rss_feed_url = nil
      expect(subject.project_name).to be_nil
    end

    it "should extract the project name from the RSS url" do
      subject.cruise_control_rss_feed_url = "http://example.com/baz.rss"
      expect(subject.project_name).to eq("baz")
    end

    it "should extract the project name from the RSS url regardless of capitalization" do
      subject.cruise_control_rss_feed_url = "HTTP://EXAMPLE.COM/BAZ.RSS"
      expect(subject.project_name).to eq("BAZ")
    end
  end

end
