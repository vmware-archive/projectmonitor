require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe AuthConfig do
  it "should have an auth_required" do
    AuthConfig.auth_required.should == false
  end

  describe "OAuth config" do
    it "should have a consumer key" do
      AuthConfig.consumer_key.should_not be_blank
    end

    it "should have a consumer secret" do
      AuthConfig.consumer_secret.should_not be_blank
    end

    it "should have a contacts scope" do
      AuthConfig.scope.should == "https://www.google.com/m8/feeds/"
    end

    it "should have a site" do
      AuthConfig.site.should == "https://www.google.com"
    end

    it "should have a request_token_path" do
      AuthConfig.request_token_path.should == "/accounts/OAuthGetRequestToken"
    end

    it "should have access_token_path" do

      AuthConfig.access_token_path.should == "/accounts/OAuthGetAccessToken"
    end

    it "should have an authorize_path" do
      AuthConfig.authorize_path.should == "/accounts/OAuthAuthorizeToken"
    end

    it "should have a signature_method" do
      AuthConfig.signature_method.should == "HMAC-SHA1"
    end

    it "should have authorized domains" do
      AuthConfig.authorized_domains.should == ["example.com", "anotherexample.com"]
    end
  end
end

