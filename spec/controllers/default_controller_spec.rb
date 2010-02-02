require File.dirname(__FILE__) + '/../spec_helper'

describe DefaultController do
  integrate_views

  describe "#show" do
    it "should extract tags" do
      get :show, :tags => 'foo,bar'
      assigns[:tags].should == 'foo,bar'
    end
  end
end