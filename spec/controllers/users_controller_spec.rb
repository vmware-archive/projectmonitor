require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController do
  fixtures :users

  # TODO: Test breaks when before_filter :login_required is added to UsersController
  # it 'allows signup' do
  #   lambda do
  #     create_user
  #     response.should be_redirect
  #   end.should change(User, :count).by(1)
  # end

  

  # TODO: Test breaks when before_filter :login_required is added to UsersController
  # it 'requires login on signup' do
  #   lambda do
  #     create_user(:login => nil)
  #     assigns[:user].errors.on(:login).should_not be_nil
  #     response.should be_success
  #   end.should_not change(User, :count)
  # end
  
  # TODO: Test breaks when before_filter :login_required is added to UsersController
  # it 'requires password on signup' do
  #   lambda do
  #     create_user(:password => nil)
  #     assigns[:user].errors.on(:password).should_not be_nil
  #     response.should be_success
  #   end.should_not change(User, :count)
  # end
  
  # TODO: Test breaks when before_filter :login_required is added to UsersController
  # it 'requires password confirmation on signup' do
  #   lambda do
  #     create_user(:password_confirmation => nil)
  #     assigns[:user].errors.on(:password_confirmation).should_not be_nil
  #     response.should be_success
  #   end.should_not change(User, :count)
  # end

  # TODO: Test breaks when before_filter :login_required is added to UsersController
  # it 'requires email on signup' do
  #   lambda do
  #     create_user(:email => nil)
  #     assigns[:user].errors.on(:email).should_not be_nil
  #     response.should be_success
  #   end.should_not change(User, :count)
  # end
  
  
  
  def create_user(options = {})
    post :create, :user => { :login => 'quire', :email => 'quire@example.com',
      :password => 'quire69', :password_confirmation => 'quire69' }.merge(options)
  end
end

describe UsersController do
  describe "route generation" do
    it "should route users's 'index' action correctly" do
      route_for(:controller => 'users', :action => 'index').should == "/users"
    end
    
    it "should route users's 'new' action correctly" do
      route_for(:controller => 'users', :action => 'new').should == "/signup"
    end
    
    it "should route {:controller => 'users', :action => 'create'} correctly" do
      route_for(:controller => 'users', :action => 'create').should == "/register"
    end
    
    it "should route users's 'show' action correctly" do
      route_for(:controller => 'users', :action => 'show', :id => '1').should == "/users/1"
    end
    
    it "should route users's 'edit' action correctly" do
      route_for(:controller => 'users', :action => 'edit', :id => '1').should == "/users/1/edit"
    end
    
    it "should route users's 'update' action correctly" do
      route_for(:controller => 'users', :action => 'update', :id => '1').should == { :path => "/users/1", :method => "put" }
    end
    
    it "should route users's 'destroy' action correctly" do
      route_for(:controller => 'users', :action => 'destroy', :id => '1').should ==  { :path => "/users/1", :method => "delete" }
    end
  end
  
  describe "route recognition" do
    it "should generate params for users's index action from GET /users" do
      params_from(:get, '/users').should == {:controller => 'users', :action => 'index'}
      params_from(:get, '/users.xml').should == {:controller => 'users', :action => 'index', :format => 'xml'}
      params_from(:get, '/users.json').should == {:controller => 'users', :action => 'index', :format => 'json'}
    end
    
    it "should generate params for users's new action from GET /users" do
      params_from(:get, '/users/new').should == {:controller => 'users', :action => 'new'}
      params_from(:get, '/users/new.xml').should == {:controller => 'users', :action => 'new', :format => 'xml'}
      params_from(:get, '/users/new.json').should == {:controller => 'users', :action => 'new', :format => 'json'}
    end
    
    it "should generate params for users's create action from POST /users" do
      params_from(:post, '/users').should == {:controller => 'users', :action => 'create'}
      params_from(:post, '/users.xml').should == {:controller => 'users', :action => 'create', :format => 'xml'}
      params_from(:post, '/users.json').should == {:controller => 'users', :action => 'create', :format => 'json'}
    end
    
    it "should generate params for users's show action from GET /users/1" do
      params_from(:get , '/users/1').should == {:controller => 'users', :action => 'show', :id => '1'}
      params_from(:get , '/users/1.xml').should == {:controller => 'users', :action => 'show', :id => '1', :format => 'xml'}
      params_from(:get , '/users/1.json').should == {:controller => 'users', :action => 'show', :id => '1', :format => 'json'}
    end
    
    it "should generate params for users's edit action from GET /users/1/edit" do
      params_from(:get , '/users/1/edit').should == {:controller => 'users', :action => 'edit', :id => '1'}
    end
    
    it "should generate params {:controller => 'users', :action => update', :id => '1'} from PUT /users/1" do
      params_from(:put , '/users/1').should == {:controller => 'users', :action => 'update', :id => '1'}
      params_from(:put , '/users/1.xml').should == {:controller => 'users', :action => 'update', :id => '1', :format => 'xml'}
      params_from(:put , '/users/1.json').should == {:controller => 'users', :action => 'update', :id => '1', :format => 'json'}
    end
    
    it "should generate params for users's destroy action from DELETE /users/1" do
      params_from(:delete, '/users/1').should == {:controller => 'users', :action => 'destroy', :id => '1'}
      params_from(:delete, '/users/1.xml').should == {:controller => 'users', :action => 'destroy', :id => '1', :format => 'xml'}
      params_from(:delete, '/users/1.json').should == {:controller => 'users', :action => 'destroy', :id => '1', :format => 'json'}
    end
  end
  
  describe "named routing" do
    before(:each) do
      get :new
    end
    
    it "should route user_(:id => '1') to /users/1" do
      user_path(:id => '1').should == "/users/1"
    end
    
    it "should route edit_user_path(:id => '1') to /users/1/edit" do
      edit_user_path(:id => '1').should == "/users/1/edit"
    end
  end
  
end
