require 'spec_helper'

describe DefaultController do
  it "should extract tags on show" do
    get :show, :tags => 'foo,bar'
    response.should be_success
    assigns[:tags].should == 'foo,bar'
  end
  
  it "should route iphone to cimonitor" do
    get :show, :format => 'iphone'
    response.should redirect_to('/dashboard')
  end
end