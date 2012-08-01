require 'spec_helper'

describe VersionsController do
  context 'routing' do
    it 'should route GET /version to VersionsController#show' do
      { get: '/version' }.should route_to(:controller => 'versions', :action => 'show')
    end
  end

  context 'with a VERSION file in the Rails root' do
    let(:version) { '123' }
    before do
      File.stub(:exists?).with(VersionsController::VERSION_PATH).and_return(true)
      File.stub(:read).with(VersionsController::VERSION_PATH).and_return(version)
    end

    it 'returns the current version' do
      get :show
      response.body.should == version
    end
  end

  context 'with no VERSION file in the Rails root' do
    before do
      File.stub(:exists?).with(VersionsController::VERSION_PATH).and_return(false)
    end

    it 'returns the current version' do
      get :show
      response.body.should == VersionsController::DEFAULT_VERSION
    end
  end
end
