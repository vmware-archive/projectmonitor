require 'spec_helper'

describe "projects/new" do
  before do
    @project = Project.new
  end

  it "should include the server time" do
    Clock.now = Time.parse("Wed Oct 26 17:02:10 -0700 2011")
    render
    rendered.should include("Server time is #{Clock.now.to_s}")
  end
end

