require File.expand_path(File.join(File.dirname(__FILE__),'..','spec_helper'))

describe ProjectsController do
  describe "with no logged in user" do
    describe "all actions" do
      it "should redirect to the login page" do
        get :index
        response.should redirect_to(login_path)
      end
    end
  end

  describe "with a logged in user" do
    before(:each) do
      log_in(users(:valid_edward))
    end

    it "should respond to index" do
      get :index
      response.should be_success
      assigns(:projects).should_not be_nil
    end

    it "should respond to new" do
      get :new
      response.should be_success
    end

    it "should create projects by type" do
      lambda do
        post :create, :project => {:name=>'name', :feed_url=>'http://www.example.com/job/example/rssAll', :type => HudsonProject.name}
      end.should change(HudsonProject, :count).by(1)
      response.should redirect_to(projects_path)
    end

    it "should respond to edit" do
      get :edit, :id => projects(:socialitis)
      response.should be_success
    end

    it "should respond to update" do
      put :update, :id => projects(:socialitis), :project => { }
      response.should redirect_to(projects_path)
    end

    it "should respond to destroy" do
      old_count = Project.count
      delete :destroy, :id => projects(:socialitis)
      Project.count.should == old_count - 1

      response.should redirect_to(projects_path)
    end
  end
end
