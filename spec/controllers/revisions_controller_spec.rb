require 'spec_helper'

describe RevisionsController do
  context 'with a REVISION file in the Rails root' do
    let(:revision) { '123' }

    before do
      File.stub(:read).with(RevisionsController::REVISION_PATH).and_return(revision)
    end

    it 'returns the current revision' do
      get :show
      response.body.should == revision
    end

    it 'should route GET /revision to RevisionsController#show' do
      { get: '/revision' }.should route_to(:controller => 'revisions', :action => 'show')
    end
  end

  context 'with no REVISION file in the Rails root' do
    it 'returns the current revision' do
      get :show
      response.body.should == RevisionsController::DEFAULT_REVISION
    end

    it 'should route GET /revision to RevisionsController#show' do
      { get: '/revision' }.should route_to(:controller => 'revisions', :action => 'show')
    end
  end
end
