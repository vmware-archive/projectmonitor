require 'spec_helper'

describe DashboardsController do

  describe '#index' do
    let(:projects) { [double(:project)] }
    let(:aggregate_projects) { [double(:aggregate_project)] }
    let(:tiles) { projects + aggregate_projects }

    before do
      Project.stub(displayable: projects)
      AggregateProject.stub(displayable: aggregate_projects)
      DashboardGrid.stub(arrange: tiles)
      controller.stub(:respond_with)
    end

    let(:tag) { 'location' }
    subject { get :index, :tag => tag }

    it 'should render_template :index' do
      get :index, :format => :html
      response.should render_template :index
    end

    it 'gets a collection of displayable projects by tag' do
      Project.should_receive(:displayable).with(tag)
      subject
    end

    it 'gets a collection of aggregate projects by tag' do
      AggregateProject.should_receive(:displayable).with(tag)
      subject
    end

    it 'arranges the projects into tiles' do
      DashboardGrid.should_receive(:arrange).with(tiles, {})
      subject
    end

    it 'should respond with the tiles' do
      controller.should_receive(:respond_with).with(tiles)
      subject
    end
  end

end
