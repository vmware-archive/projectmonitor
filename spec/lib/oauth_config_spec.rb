require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe GoogleOAuthConfig do
  it "should have a consumer key" do
    GoogleOAuthConfig.consumer_key.should_not be_blank
  end

  it "should have a consumer secret" do
    GoogleOAuthConfig.consumer_secret.should_not be_blank
  end

  it "should have a contacts scope" do
    GoogleOAuthConfig.scope.should == "https://www.google.com/m8/feeds/"
  end

  it "should have a site" do
    GoogleOAuthConfig.site.should == "https://www.google.com"
  end

  it "should have a request_token_path" do
    GoogleOAuthConfig.request_token_path.should == "/accounts/OAuthGetRequestToken"
  end

  it "should have access_token_path" do

    GoogleOAuthConfig.access_token_path.should == "/accounts/OAuthGetAccessToken"
  end

  it "should have an authorize_path" do
    GoogleOAuthConfig.authorize_path.should == "/accounts/OAuthAuthorizeToken"
  end

  it "should have a " do
    GoogleOAuthConfig.signature_method.should == "HMAC-SHA1"
  end
end