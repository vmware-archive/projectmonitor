require 'spec_helper'
require 'time'

describe ProjectsController do
  render_views
  
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
      assigns(:aggregate_projects).should_not be_nil
    end

    it "should respond to new" do
      get :new
      response.should be_success
    end
    
    it "should show you the time when you are creating a new project" do
      Clock.now = Time.parse("Wed Oct 26 17:02:10 -0700 2011")
      get :new
      response.body.should include("Server time is Wed Oct 26 17:02:10 -0700 2011")
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

    context "#update" do
      it "should respond to update" do
        put :update, :id => projects(:socialitis), :project => { }
        response.should redirect_to(projects_path)
      end

      it "allows changing the type" do
        project = HudsonProject.create(:name => "HP to CCP", :feed_url => "http://www.example.com/job/example/rssAll")
        project.should be_valid
        project.should be_a_kind_of(HudsonProject)

        put :update, :id => project.to_param, :project => { :type => "CruiseControlProject", :feed_url => "http://redrover.dyndns-ip.com:8111/app/rest/builds?locator=running:all,buildType:(id:bt10).rss" }

        assigns(:project).should be_valid
        assigns(:project).should be_a_kind_of(CruiseControlProject)
      end

      it "changing type is atomic" do
        project = projects(:pivots)
        project.should be_a_kind_of(CruiseControlProject)

        put :update, :id => project.to_param, :project => { :type => "HudsonProject" }
        response.should be_success
        response.should render_template('edit')
        Project.find(project.id).should be_a_kind_of(CruiseControlProject)
      end
    end

    it "should respond to destroy" do
      old_count = Project.count
      delete :destroy, :id => projects(:socialitis)
      Project.count.should == old_count - 1

      response.should redirect_to(projects_path)
    end
  end
end
