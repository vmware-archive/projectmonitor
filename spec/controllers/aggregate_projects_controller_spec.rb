require 'spec_helper'

describe AggregateProjectsController do
  describe "with no logged in user" do
    describe "show" do
      let(:aggregate_project) { aggregate_projects(:internal_projects_aggregate) }
      before { get :show, :id => aggregate_project.to_param }

      it "should be_success" do
        response.should be_success
      end

      it "should render dashboards/index" do
        response.should render_template("dashboards/index")
      end
    end

    describe "status" do
      let(:aggregate_project) { aggregate_projects(:internal_projects_aggregate) }
      before { get :status, :id => aggregate_project.to_param }

      it "should render dashboards/_project" do
        response.should render_template("dashboards/_project")
      end
    end
  end

  describe "with a logged in user" do
    before { log_in users(:valid_edward) }

    describe "create" do
      context "when the aggregate project was successfully created" do
        before { post :create, :aggregate_project => { :name => "new name" } }

        it "should set the flash" do
          flash[:notice].should == 'Aggregate project was successfully created.'
        end

        it { should redirect_to projects_path }
      end

      context "when the aggregate project was not successfully created" do
        before { post :create, :aggregate_project => { :name => nil } }
        it { should render_template :new }
      end
    end

    describe "update" do
      context "when the aggregate project was successfully updated" do
        before { put :update, :id => aggregate_projects(:internal_projects_aggregate), :aggregate_project => { :name => "new name" } }

        it "should set the flash" do
          flash[:notice].should == 'Aggregate project was successfully updated.'
        end

        it { should redirect_to projects_url }
      end

      context "when the aggregate project was not successfully updated" do
        before { put :update, :id => aggregate_projects(:internal_projects_aggregate), :aggregate_project => { :name => nil } }
        it { should render_template :edit }
      end
    end

    describe "destroy" do
      subject { delete :destroy, :id => aggregate_projects(:internal_projects_aggregate) }

      it "should destroy the aggregate project" do
        lambda { subject }.should change(AggregateProject, :count).by(-1)
      end

      it "should set the flash" do
        subject
        flash[:notice].should == 'Aggregate project was successfully destroyed.'
      end

      it { should redirect_to projects_url }
    end
  end
end
