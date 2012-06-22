require 'spec_helper'

class VersionsController
  DEFAULT_VERSION = '-1 (for testing)'
end

describe VersionsController do
  context 'routing' do
    it 'should route GET /version to VersionsController#show' do
      { get: '/version' }.should route_to(:controller => 'versions', :action => 'show')
    end
  end

  context 'with a VERSION file in the Rails root' do
    let(:version) { '123' }

    it 'should find the file' do
      get :show
      response.body.should_not == VersionsController::DEFAULT_VERSION
    end

    it 'returns the current version' do
      File.stub(:read).with(VersionsController::VERSION_PATH).and_return(version)
      get :show
      response.body.should == version
    end

    it 'should route GET /version to VersionsController#show' do
      { get: '/version' }.should route_to(:controller => 'versions', :action => 'show')
    end
  end

  context 'with no VERSION file in the Rails root' do

    it 'returns the current version' do
      File.stub(:read).and_raise(Errno::ENOENT)
      get :show
      response.body.should == VersionsController::DEFAULT_VERSION
    end
  end
end
