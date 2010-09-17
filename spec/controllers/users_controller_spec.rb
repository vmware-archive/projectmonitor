require File.expand_path(File.join(File.dirname(__FILE__),'..','spec_helper'))

describe UsersController do
  it "requires login" do
    get :new
    response.should redirect_to(login_path)
  end

  describe "logged in as a user" do
    before(:each) do
      log_in(create_user)
    end

    it "shows a signup page" do
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
    params_from(:get, '/users/new').should == {:controller => 'users', :action => 'new'}
    params_from(:post, '/users').should == {:controller => 'users', :action => 'create'}
  end
end
