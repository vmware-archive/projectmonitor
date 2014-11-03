require 'spec_helper'

describe TeamCityProject, :type => :model do

  subject { build(:team_city_project) }

  describe 'validations' do
    context "when webhooks are enabled" do
      subject { Project.new(webhooks_enabled: true)}
      it { is_expected.not_to validate_presence_of(:ci_base_url) }
      it { is_expected.not_to validate_presence_of(:team_city_build_id) }
    end

    context "when webhooks are not enabled" do
      it { is_expected.to validate_presence_of(:ci_base_url) }
      it { is_expected.to validate_presence_of(:team_city_build_id) }

      it { is_expected.to allow_value('bt123', 'bt1').for(:team_city_build_id) }
      it { is_expected.not_to allow_value('x123', "karate chop!\nbt123").for(:team_city_build_id) }
    end
  end

  describe '#feed_url' do
    subject { super().feed_url }
    it { is_expected.to eq("http://foo.bar.com:1234/guestAuth/cradiator.html?buildTypeId=bt567") }
  end

  describe '#project_name' do
    subject { super().project_name }
    it { is_expected.to eq("http://foo.bar.com:1234/guestAuth/cradiator.html?buildTypeId=bt567") }
  end

  describe '#build_status_url' do
    subject { super().build_status_url }
    it { is_expected.to eq("http://foo.bar.com:1234/guestAuth/cradiator.html?buildTypeId=bt567") }
  end

end
