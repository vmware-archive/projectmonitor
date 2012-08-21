require 'spec_helper'

describe TeamCityRestProject do
  subject { FactoryGirl.build(:team_city_rest_project) }

  describe 'factories' do
    subject { FactoryGirl.build(:team_city_rest_project) }
    it { should be_valid }
  end

  describe 'validations' do
    context "when webhooks are enabled" do
      subject { Project.new(webhooks_enabled: true)}
      it { should_not validate_presence_of(:team_city_rest_base_url) }
      it { should_not validate_presence_of(:team_city_rest_build_type_id) }
    end

    context "when webhooks are not enabled" do
      it { should validate_presence_of(:team_city_rest_base_url) }
      it { should validate_presence_of(:team_city_rest_build_type_id) }

      it { should allow_value('bt123', 'bt1').for(:team_city_rest_build_type_id) }
      it { should_not allow_value('x123', "karate chop!\nbt123").for(:team_city_rest_build_type_id) }
    end
  end

  # FIXME: This is effectively broken as you cannot set the feed_url using the GUI!
  # context "TeamCity REST API feed with both the personal and user option" do
  # it "should be valid" do
  # project.feed_url = "#{rest_url},user:some_user123,personal:true"
  # project.should be_valid
  # end
  # end

  its(:feed_url) { should == "http://example.com/app/rest/builds?locator=running:all,buildType:(id:bt456),personal:false" }
  its(:project_name) { should == "http://example.com/app/rest/builds?locator=running:all,buildType:(id:bt456),personal:false" }
  its(:build_status_url) { should == "http://example.com/app/rest/builds?locator=running:all,buildType:(id:bt456),personal:false" }
  its(:dependent_build_info_url) { should == "http://example.com/httpAuth/app/rest/buildTypes/id:bt456" }

  describe '#current_build_url' do
    subject { project.current_build_url }
    context "webhooks are disabled" do
      let(:project) { FactoryGirl.build(:team_city_rest_project) }

      it { should == 'http://example.com/viewType.html?tab=buildTypeStatusDiv&buildTypeId=bt456' }
    end

    context "webhooks are enabled" do
      let(:project) { FactoryGirl.build(:team_city_rest_project, webhooks_enabled: true, parsed_url: 'foo.gov') }

      it { should == 'foo.gov' }
    end
  end
end
