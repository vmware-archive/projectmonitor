require 'spec_helper'

describe VersionsController, :type => :controller do
  before(:each) do
    VersionsController.class_eval {class_variable_set :@@version, nil}
  end

  context 'routing' do
    it 'should route GET /version to VersionsController#show' do
      expect({ get: '/version' }).to route_to(controller: 'versions', action: 'show')
    end

    it 'should only check the VERSION file once' do
      expect(File).to receive(:exists?).once
      3.times { get :show }
    end
  end

  context 'with a VERSION file in the Rails root' do
    let(:version) { '123' }
    before do
      allow(File).to receive(:exists?).with(VersionsController::VERSION_PATH).and_return(true)
      allow(File).to receive(:read).with(VersionsController::VERSION_PATH).and_return(version)
    end

    it 'returns the current version' do
      get :show
      expect(response.body).to eq(version)
    end
  end

  context 'with no VERSION file in the Rails root' do
    before do
      allow(File).to receive(:exists?).with(VersionsController::VERSION_PATH).and_return(false)
    end

    it 'returns the current version' do
      get :show
      expect(response.body).to eq(VersionsController::DEFAULT_VERSION)
    end
  end
end
