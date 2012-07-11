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
        post :create, :project => {:name=>'name', :feed_url=>'http://www.example.com/job/example/rssAll', :type => JenkinsProject.name}
      end.should change(JenkinsProject, :count).by(1)
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
