require 'spec_helper'

describe TeamCityChainedProject do
  let(:feed_url) { "http://localhost:8111/app/rest/builds?locator=running:all,buildType:(id:#{build_type_id})" }
  let(:build_type_id) { "bt1" }
  let(:project) {
    TeamCityChainedProject.new(
      :name => 'TeamCityproject',
      :feed_url => feed_url,
      :auth_username => "john",
      :auth_password => "secret"
    )
  }

  describe "#build_type_id" do
    it "should use the build id in the feed_url" do
      project.build_type_id.should == build_type_id
    end
  end
end
