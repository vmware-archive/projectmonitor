require 'spec_helper'

describe OpenidsController do
  before(:each) do
    AuthConfig.stub(:auth_file_path).and_return(Rails.root.join("spec/fixtures/files/auth-openid.yml"))
  end

  it "should route" do
    {:get => '/openid/new'}.should route_to(:controller => "openids", :action => "new")
    {:get => '/openid/success'}.should route_to(:controller => "openids", :action => "success")
  end

  describe "GET new" do
    before(:each) do
      @consumer = mock("openid consumer")
      controller.stub!(:get_openid_consumer).and_return(@consumer)
    end

    it "should ask the API's openid consumer for a check request" do
      checkid_request = mock()
      checkid_request.should_receive(:redirect_url).with("http://example.com", "http://example.com/openid/success")

      @consumer.should_receive(:begin).with("example.com").and_return(checkid_request)

      get :new
      response.should redirect_to("http://test.host&openid.ns.ext1=http://openid.net/srv/ax/1.0&openid.ext1.mode=fetch_request&openid.ext1.type.email=http://axschema.org/contact/email&openid.ext1.type.firstName=http://axschema.org/namePerson/first,&openid.ext1.type.lastName=http://axschema.org/namePerson/last,&openid.ext1.required=email,firstName,lastName")
    end

  end

  describe "GET success" do
    before(:each) do
      @consumer = mock("openid consumer")
      controller.stub!(:get_openid_consumer).and_return(@consumer)
    end

    it "should get a fetch response" do
      consumer_response = mock()

      @consumer.should_receive(:complete).and_return(consumer_response)

      fetch_response = mock()
      fetch_response.should_receive(:get_single).once.with('http://axschema.org/contact/email').and_return("email@example.com")
      fetch_response.should_receive(:get_single).once.with('http://axschema.org/namePerson/first').and_return("First")
      fetch_response.should_receive(:get_single).once.with('http://axschema.org/namePerson/last').and_return("Last")

      OpenID::AX::FetchResponse.should_receive(:from_success_response).with(consumer_response).and_return(fetch_response)

      get :success

      response.should redirect_to(root_path)
      current_user.name.should == "First Last"
      current_user.login.should == "email"
      current_user.email.should == "email@example.com"
    end

    it "should redirect to project page when user cancels login" do
      get :success, "openid.mode" => "cancel"
      response.should redirect_to(root_path)
    end
  end
end