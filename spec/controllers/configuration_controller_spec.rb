require 'spec_helper'

describe ConfigurationController do
  before { sign_in FactoryGirl.create(:user) }

  describe '#index' do
    subject { get :show }

    it 'should return the configuration' do
      ConfigExport.should_receive(:export)
      subject
    end
  end

  describe '#update' do
    subject do
      post :create, content: fixture_file_upload('/files/configuration.yml')
    end

    it 'should change the configuration' do
      ConfigExport.should_receive(:import).with("---\naggregated_projects: []\nprojects: []\n")
      subject
    end
  end
end
