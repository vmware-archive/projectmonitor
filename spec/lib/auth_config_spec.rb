require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe AuthConfig do
  it "should have an auth_required" do
    AuthConfig.auth_required.should == false
  end

  describe "openid config" do
    it "should have an openid identifier" do
      AuthConfig.openid_identifier.should == "example.com"
    end

    it "should have an openid realm" do
      AuthConfig.openid_realm.should == "http://example.com"
    end

    it "should have an openid return_to" do
      AuthConfig.openid_return_to.should == "http://example.com/openid/success"
    end
  end
end

