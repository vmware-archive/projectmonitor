require 'spec_helper'

describe DashboardsController do

  describe '#index' do
    let(:projects) { [double(:project, code: "foo")] }
    let(:aggregate_projects) { [double(:aggregate_project, code: "bar")] }
    let(:tiles) { aggregate_projects | projects }

    context 'when an aggregate project id is specified' do
      before do
        AggregateProject.stub_chain(:find, :projects, :displayable, :all).and_return([])
      end

      subject { get :index, aggregate_project_id: 1 }

      it 'loads the specified project' do
        AggregateProject.should_receive(:find).with('1')
        subject
      end

      context 'when no tile count is passed in' do
        it 'should limit the tiles by 15' do
          proxy = double
          ProjectDecorator.stub_chain(:decorate, :sort_by).and_return(proxy)
          proxy.should_receive(:take).with(15)
          get :index, aggregate_project_id: 1
        end
      end

      context 'when a tile count is passed in' do
        it 'should limit the tiles by the passed in amount' do
          proxy = double
          ProjectDecorator.stub_chain(:decorate, :sort_by).and_return(proxy)
          proxy.should_receive(:take).with(63)
          get :index, tiles_count: 63, aggregate_project_id: 1
        end
      end
    end

    context 'when the aggregate project id is not specified' do
      subject { get :index }

      before do
        AggregateProject.stub(:displayable).and_return([])
        Project.stub_chain(:standalone, :displayable, :all).and_return([])
        ProjectDecorator.stub_chain(:decorate, :sort_by, :take)
      end

      it 'gets a collection of aggregate projects by tag' do
        AggregateProject.should_receive(:displayable)
        subject
      end

      it 'gets a collection of displayable projects by tag' do
        proxy = double(:proxy)
        Project.should_receive(:standalone).and_return(proxy)
        proxy.should_receive(:displayable) { double(:projects, all: [])}
        subject
      end

      context 'when no tile count is passed in' do
        it 'should limit the tiles by 15' do
          proxy = double
          ProjectDecorator.stub_chain(:decorate, :sort_by).and_return(proxy)
          proxy.should_receive(:take).with(15)
          get :index
        end
      end

      context 'when a tile count is passed in' do
        it 'should limit the tiles by the passed in amount' do
          proxy = double
          ProjectDecorator.stub_chain(:decorate, :sort_by).and_return(proxy)
          proxy.should_receive(:take).with(63)
          get :index, tiles_count: 63
        end
      end

    end
  end

end
