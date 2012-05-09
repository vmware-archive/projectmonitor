require 'spec_helper'

describe RevisionsController do
  let(:revision) { '123' }

  before do
    File.stub(:read).with(File.join(Rails.root, 'REVISION')).and_return(revision)
  end

  it 'returns the current revision' do
    get :show
    response.body.should == revision
  end

  it 'should route GET /revision to RevisionsController#show' do
    { get: '/revision' }.should route_to(:controller => 'revisions', :action => 'show')
  end
end
