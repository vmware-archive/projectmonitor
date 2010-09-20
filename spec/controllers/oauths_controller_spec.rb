require File.expand_path(File.join(File.dirname(__FILE__),'..','spec_helper'))
require "oauth/consumer"
require 'oauth/signature/rsa/sha1'

describe OauthsController do
  it "should route" do
    {:get => '/oauth/new'}.should route_to(:controller => "oauths", :action => "new")
    {:get => '/oauth/success'}.should route_to(:controller => "oauths", :action => "success")
  end

  describe "GET new" do
    before(:each) do
      @consumer = mock("oauth consumer")
      controller.stub!(:get_oauth_consumer).and_return(@consumer)
    end

    it "should ask the API's oauth consumer for a request token" do
      @consumer.should_receive(:get_request_token).with({:oauth_callback => success_oauth_url},
                                                        {:scope => "https://www.google.com/m8/feeds/"}).and_return(mock(
        :secret => "oauth_secret",
        :authorize_url => "http://authorize_url?foo=bar"
      ))
      get :new
      session[:oauth_secret].should == "oauth_secret"
      response.should redirect_to("http://authorize_url?foo=bar")
    end
  end

  describe "GET success" do
    before(:each) do
      @consumer = mock("oauth consumer")
      controller.stub!(:get_oauth_consumer).and_return(@consumer)
    end

    it "should get an access token from the request token received from OAuth" do
      sample_user_response = <<-eos
<?xml version='1.0' encoding='UTF-8'?>
<feed>
  <author><name>First Last</name><email>email@example.com</email></author>
</feed>
      eos
      access_token = mock(:token => "accesstoken", :secret => "accesssecret", :get => mock(:body => sample_user_response))
      request_token = mock
      OAuth::RequestToken.should_receive(:new).with(@consumer, "oauth_token", "oauth_secret").and_return(request_token)
      request_token.should_receive(:get_access_token).and_return(access_token)

      request.session[:oauth_secret] = "oauth_secret"
      get :success, :oauth_token => "oauth_token"

      response.should redirect_to(root_path)
      current_user.name.should == "First Last"
      current_user.login.should == "email"
      current_user.email.should == "email@example.com"
    end
  end
end