require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe AuthConfig do
  it "should have an auth_required" do
    AuthConfig.auth_required.should == false
  end
end

