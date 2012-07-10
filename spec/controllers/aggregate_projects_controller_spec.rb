require 'spec_helper'

describe AggregateProjectsController do
  let(:page) { Capybara::Node::Simple.new(response.body) }

  describe "#status" do
    let(:project) { aggregate_projects(:internal_projects_aggregate) }
    before { get :status, :id => project.id }

    it { response.should render_template("dashboards/_project") }
  end

  describe "with no logged in user" do
    let(:ap) { aggregate_projects(:internal_projects_aggregate) }

    it "should respond to new" do
      get :show, :id => ap.to_param
      response.should be_success
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
      put :update, :id => aggregate_projects(:internal_projects_aggregate), :project => {}
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
