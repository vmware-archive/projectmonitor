require 'spec_helper'

describe TeamCityRestProject, :type => :model do
  subject { FactoryGirl.build(:team_city_rest_project) }

  describe 'factories' do
    subject { FactoryGirl.build(:team_city_rest_project) }
    it { is_expected.to be_valid }
  end

  describe 'validations' do
    context "when webhooks are enabled" do
      subject { Project.new(webhooks_enabled: true)}
      it { is_expected.not_to validate_presence_of(:team_city_rest_base_url) }
      it { is_expected.not_to validate_presence_of(:team_city_rest_build_type_id) }
    end

    context "when webhooks are not enabled" do
      it { is_expected.to validate_presence_of(:team_city_rest_base_url) }
      it { is_expected.to validate_presence_of(:team_city_rest_build_type_id) }

      it { is_expected.to allow_value('bt123', 'bt1').for(:team_city_rest_build_type_id) }
      it { is_expected.not_to allow_value('x123', "karate chop!\nbt123").for(:team_city_rest_build_type_id) }
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
