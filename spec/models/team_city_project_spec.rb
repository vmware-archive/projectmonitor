require 'spec_helper'

describe TeamCityProject do

  subject { FactoryGirl.build(:team_city_project) }

  describe 'factories' do
    subject { FactoryGirl.build(:team_city_project) }
    it { should be_valid }
  end

  describe 'validations' do
    context "when webhooks are enabled" do
      subject { Project.new(webhooks_enabled: true)}
      it { should_not validate_presence_of(:team_city_base_url) }
      it { should_not validate_presence_of(:team_city_build_id) }
    end

    context "when webhooks are not enabled" do
      it { should validate_presence_of(:team_city_base_url) }
      it { should validate_presence_of(:team_city_build_id) }

      it { should allow_value('bt123', 'bt1').for(:team_city_build_id) }
      it { should_not allow_value('x123', "karate chop!\nbt123").for(:team_city_build_id) }
    end
  end

  its(:feed_url) { should == "http://foo.bar.com:1234/guestAuth/cradiator.html?buildTypeId=bt567" }
  its(:project_name) { should == "http://foo.bar.com:1234/guestAuth/cradiator.html?buildTypeId=bt567" }
  its(:build_status_url) { should == "http://foo.bar.com:1234/guestAuth/cradiator.html?buildTypeId=bt567" }

end
