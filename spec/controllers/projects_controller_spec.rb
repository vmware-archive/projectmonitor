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
      sign_in FactoryGirl.create(:user)
    end

    context "when nested under an aggregate project" do
      it "should scope by aggregate_project_id" do
        Project.should_receive(:with_aggregate_project).with('1')
        get :index, aggregate_project_id: 1
      end
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

        it { should redirect_to edit_configuration_path }
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

        it { should redirect_to edit_configuration_path }
      end

      context "when the project was not successfully updated" do
        before { put :update, :id => projects(:jenkins_project), :project => { :name => nil } }
        it { should render_template :edit }
      end

      describe "posting empty feed password" do
        [nil, '', "", []].each do |empty|
          before { put :update, :id => project.id, :project => { :name => "new name", auth_password: empty } }
          subject { response }
          context "when there is already a feed password" do
            let(:project) { FactoryGirl.create(:jenkins_project, auth_password: 'google') }
            it "should preserve the feed password" do
              subject
              project.reload.auth_password.should == 'google'
            end
          end
        end
      end
      describe "posting valid feed password" do
        before { put :update, :id => project.id, :project => { :name => "new name", auth_password: 'google' } }
        let(:project) { FactoryGirl.create(:jenkins_project, auth_password: 'froogle') }
        it "should update the feed password" do
          subject
          project.reload.auth_password.should == 'google'
        end
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

      it { should redirect_to edit_configuration_path }
    end

    describe "#validate_tracker_project" do
      it "should enqueue a job" do
        project = projects(:jenkins_project)
        TrackerProjectValidator.should_receive(:delay) { TrackerProjectValidator }
        TrackerProjectValidator.should_receive :validate
        post :validate_tracker_project, { auth_token: "12354", project_id: "98765", id: project.id }
      end
    end

    describe "#validate_build_info" do
      subject { response }

      before do
        JenkinsProject.should_receive(:new).and_return(project)
        ProjectUpdater.should_receive(:update).with(project)
        post :validate_build_info, :project => {:type => "JenkinsProject"}
      end

      context "project is online" do
        let(:project) { double(:project, online: true) }

        it { should be_success }
      end

      context "project is offline" do
        let(:project) { double(:project, online: false) }

        its(:status) { should == 403 }
      end
    end

    describe "#update_projects" do
      context "The queue is empty" do
        before do
          Delayed::Job.should_receive(:count) { stub(zero?: true) }
          StatusFetcher.should_receive(:fetch_all)
        end
        it "should fetch statuses" do
          post :update_projects, { auth_token: "12354" }
          response.should be_success
        end
      end
      context "The queue is not empty" do
        before do
          Delayed::Job.should_receive(:count) { stub(zero?: false) }
          StatusFetcher.should_not_receive(:fetch_all)
        end
        it "should fetch statuses" do
          post :update_projects, { auth_token: "12354" }
          response.response_code.should == 409
        end
      end
    end

  end
end
