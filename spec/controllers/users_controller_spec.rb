require 'spec_helper'

describe UsersController do
  it "requires login" do
    get :new
    response.should redirect_to(new_user_session_path)
  end

  describe "logged in as a user" do
    let(:user) { FactoryGirl.create(:user) }
    before { sign_in(user) }

    it "shows a login page" do
      get :new
      response.should be_success
      assigns(:user).should be_new_record
    end

    it "creates a new user" do
      lambda {
        post :create, :user => { :login => 'newuser', :email => 'newuser@example.com',
          :password => 'password', :password_confirmation => 'password' }
        response.should redirect_to(root_path)
        assigns(:user).should_not be_new_record
        assigns(:user).should be_valid
        assigns(:user).login.should == "newuser"
      }.should change(User, :count).by(1)
    end

    it "should handle a bad user" do
      lambda {
        post :create, :user => { :login => 'newuser', :email => 'newuser@example.com',
          :password => 'password', :password_confirmation => 'notpassword' }
        response.should be_success
        assigns(:user).should_not be_valid
      }.should change(User, :count).by(0)
    end
  end

  it "should generate params for users's new action from GET /users" do
    {:get => "/users/new"}.should route_to(:controller => 'users', :action => 'new')
    {:post => "/users"}.should route_to(:controller => 'users', :action => 'create')
  end
end
