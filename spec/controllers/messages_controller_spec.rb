require File.dirname(__FILE__) + '/../spec_helper'

describe MessagesController do
  describe "with no logged in user" do
    describe "all actions" do
      it "should redirect to the login page" do
        get :index
        response.should redirect_to(new_login_path)
      end
    end
  end

  describe "with a logged in user" do
    before(:each) do
      controller.send("current_user=",users(:valid_edward))
    end

    it "should respond to index" do
      get :index
      response.should be_success
      assigns(:messages).should_not be_nil
    end

    it "should respond to new" do
      get :new
      response.should be_success
    end

    it "should respond to create" do
      old_count = Message.count
      post :create, :message => {}
      Message.count.should == old_count

      post :create, :message => {:text=>'foo'}
      Message.count.should == old_count + 1

      response.should redirect_to(messages_path)
    end

    it "should respond to edit" do
      get :edit, :id => messages(:company_meeting)
      response.should be_success
    end

    it "should respond to update" do
      put :update, :id => messages(:company_meeting), :message => { }
      response.should redirect_to(messages_path)
    end

    it "should respond to destroy" do
      old_count = Message.count
      delete :destroy, :id => messages(:company_meeting)
      Message.count.should == old_count - 1

      response.should redirect_to(messages_path)
    end
  end
end
