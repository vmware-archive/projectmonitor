require 'spec_helper'

describe TravisProProject, :type => :model do
  describe "feed_url" do
    let (:token) { 'travisprotoken' }

    subject { TravisProProject.new(ci_auth_token: token).feed_url }

    it { is_expected.to start_with "https://api.travis-ci.com" }
    it { is_expected.to end_with "?token=#{token}" }
  end

  describe 'webhook_payload' do
    subject(:webhook_payload) { TravisProProject.new.webhook_payload }
    it 'sets is_travis_pro to true' do
      expect(webhook_payload.is_travis_pro).to be(true)
    end

  end
end