require File.expand_path(File.join(File.dirname(__FILE__),'..','spec_helper'))

describe DefaultController do
  it "should extract tags on show" do
    get :show, :tags => 'foo,bar'
    response.should be_success
    assigns[:tags].should == 'foo,bar'
  end
end