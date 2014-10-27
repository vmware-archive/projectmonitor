require 'spec_helper'

describe TravisProProject, :type => :model do
  describe "feed_url" do
    let (:token) { 'travisprotoken' }

    subject { TravisProProject.new(travis_pro_token: token).feed_url }

    it { is_expected.to start_with "https://api.travis-ci.com" }
    it { is_expected.to end_with "?token=#{token}" }
  end
end