require 'spec_helper'
require 'time'

describe HomeController do
  let!(:projects) { [FactoryGirl.create(:jenkins_project)] }
  let!(:aggregate_projects) { [FactoryGirl.create(:aggregate_project)] }

  describe "#index" do
    let(:tags) { 'bleecker' }

    before do
      AggregateProject.stub(:displayable).and_return(aggregate_projects)
      Project.stub_chain(:standalone, :displayable).and_return(projects)
      projects.stub_chain(:concat, :sort_by).and_return(projects + aggregate_projects)
    end

    it "should render collection of projects as JSON" do
      get :index, format: :json
      response.body.should == (projects + aggregate_projects).to_json
    end

    it 'gets a collection of aggregate projects by tag' do
      AggregateProject.should_receive(:displayable).with(tags)
      projects.stub(:take).and_return(projects)
      get :index, tags: tags
    end
  end
end
