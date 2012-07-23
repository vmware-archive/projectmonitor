require 'spec_helper'
require 'time'

describe ProjectsController do
  describe "without a logged in user" do
    describe "status" do
      let(:project) { projects(:socialitis) }
      before { get :status, :id => project.id, :tiles_count => 8 }

      it "should render dashboards/_project" do
        response.should render_template("dashboards/_project")
      end
    end
  end

  describe "with a logged in user" do
    before do
      log_in users(:valid_edward)
    end

    describe "create" do
      context "when the project was successfully created" do
        subject do
          post :create, :project => {
            :name => 'name',
            :type => JenkinsProject.name,
            :jenkins_base_url => 'http://www.example.com',
            :jenkins_build_name => 'example'
          }
        end

        it "should create a project of the correct type" do
          lambda { subject }.should change(JenkinsProject, :count).by(1)
        end

        it "should set the flash" do
          subject
          flash[:notice].should == 'Project was successfully created.'
        end

        it { should redirect_to projects_path }
      end

      context "when the project was not successfully created" do
        before { post :create, :project => { :name => nil, :type => JenkinsProject.name} }
        it { should render_template :new }
      end
    end

    describe "update" do
      context "when the project was successfully updated" do
        before { put :update, :id => projects(:jenkins_project), :project => { :name => "new name" } }

        it "should set the flash" do
          flash[:notice].should == 'Project was successfully updated.'
        end

        it { should redirect_to projects_url }
      end

      context "when the project was not successfully updated" do
        before { put :update, :id => projects(:jenkins_project), :project => { :name => nil } }
        it { should render_template :edit }
      end
    end

    describe "destroy" do
      subject { delete :destroy, :id => projects(:jenkins_project) }

      it "should destroy the project" do
        lambda { subject }.should change(JenkinsProject, :count).by(-1)
      end

      it "should set the flash" do
        subject
        flash[:notice].should == 'Project was successfully destroyed.'
      end

      it { should redirect_to projects_url }
    end

    describe "validate_tracker_project" do
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
