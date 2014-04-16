require 'spec_helper'

describe TravisProProject do
  describe "feed_url" do
    let (:token) { 'travisprotoken' }

    subject { TravisProProject.new(travis_pro_token: token).feed_url }

    it { should start_with "https://api.travis-ci.com" }
    it { should end_with "?token=#{token}" }
  end
end