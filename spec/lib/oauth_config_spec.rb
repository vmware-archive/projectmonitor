require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe AuthConfig do
  it "should have a consumer key" do
    AuthConfig.oauth.consumer_key.should_not be_blank
  end

  it "should have a consumer secret" do
    AuthConfig.oauth.consumer_secret.should_not be_blank
  end

  it "should have a contacts scope" do
    AuthConfig.oauth.scope.should == "https://www.google.com/m8/feeds/"
  end

  it "should have a site" do
    AuthConfig.oauth.site.should == "https://www.google.com"
  end

  it "should have a request_token_path" do
    AuthConfig.oauth.request_token_path.should == "/accounts/OAuthGetRequestToken"
  end

  it "should have access_token_path" do

    AuthConfig.oauth.access_token_path.should == "/accounts/OAuthGetAccessToken"
  end

  it "should have an authorize_path" do
    AuthConfig.oauth.authorize_path.should == "/accounts/OAuthAuthorizeToken"
  end

  it "should have a signature_method" do
    AuthConfig.oauth.signature_method.should == "HMAC-SHA1"
  end
end