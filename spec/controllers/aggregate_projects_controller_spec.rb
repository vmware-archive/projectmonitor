require 'spec_helper'

describe AggregateProjectsController do
  describe "with no logged in user" do
    describe "all actions" do
      it "should redirect to the login page" do
        get :new
        response.should redirect_to(login_path)
      end
    end
  end

  describe "with a logged in user" do
    before(:each) do
      log_in(users(:valid_edward))
    end

    it "should respond to new" do
      get :new
      response.should be_success
    end

    it "should respond to edit" do
      get :edit, :id => aggregate_projects(:internal_projects_aggregate)
      response.should be_success
    end

    it "should respond to update" do
      put :update, :id => aggregate_projects(:internal_projects_aggregate), :project => { }
      response.should redirect_to(projects_path)
    end

    it "should respond to destroy" do
      lambda {
        delete :destroy, :id => aggregate_projects(:internal_projects_aggregate)
      }.should change(AggregateProject, :count).by(-1)
      response.should redirect_to(projects_path)
    end
  end
end
