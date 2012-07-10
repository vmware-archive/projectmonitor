require 'spec_helper'
require 'time'

describe ProjectsController do
  describe "#status" do
    let(:project) { projects(:socialitis) }
    before { get :status, :id => project.id, :projects_count => 8 }

    it "should render dashboards/_project" do
      response.should render_template("dashboards/_project")
    end
  end

  describe "with a logged in user" do
    before(:each) do
      log_in(users(:valid_edward))
    end

    it "should respond to index" do
      get :index
      response.should be_success
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

    describe "#validate_tracker_project" do
      let(:status) { :ok }

      subject { response }

      before do
        TrackerProjectValidator.stub(:validate).and_return status
        post :validate_tracker_project, { auth_token: "12354", project_id: "98765" }
      end

      it { should be_success }
    end
  end
end
