require 'spec_helper'

describe TeamCityRestProject, :type => :model do
  subject { build(:team_city_rest_project) }

  describe 'validations' do
    context "when webhooks are enabled" do
      subject { Project.new(webhooks_enabled: true)}
      it { is_expected.not_to validate_presence_of(:ci_base_url) }
      it { is_expected.not_to validate_presence_of(:ci_build_identifier) }
    end

    context "when webhooks are not enabled" do
      it { is_expected.to validate_presence_of(:ci_base_url) }
      it { is_expected.to validate_presence_of(:ci_build_identifier) }

      it { is_expected.to allow_value('bt123', 'bt1').for(:ci_build_identifier) }
      it { is_expected.not_to allow_value('x123', "karate chop!\nbt123").for(:ci_build_identifier) }
    end
  end

  # FIXME: This is effectively broken as you cannot set the feed_url using the GUI!
  # context "TeamCity REST API feed with both the personal and user option" do
  # it "should be valid" do
  # project.feed_url = "#{rest_url},user:some_user123,personal:true"
  # project.should be_valid
  # end
  # end

  describe '#feed_url' do
    subject { super().feed_url }
    it { is_expected.to eq("http://example.com/app/rest/builds?locator=running:all,buildType:(id:bt456),personal:false") }
  end

  describe '#project_name' do
    subject { super().project_name }
    it { is_expected.to eq("http://example.com/app/rest/builds?locator=running:all,buildType:(id:bt456),personal:false") }
  end

  describe '#build_status_url' do
    subject { super().build_status_url }
    it { is_expected.to eq("http://example.com/app/rest/builds?locator=running:all,buildType:(id:bt456),personal:false") }
  end

end
