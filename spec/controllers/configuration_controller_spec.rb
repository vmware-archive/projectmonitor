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

  describe '#create' do
    subject do
      post :create, content: fixture_file_upload('/files/empty_configuration.yml')
    end

    it 'should change the configuration' do
      ConfigExport.should_receive(:import).with("---\naggregated_projects: []\nprojects: []\n")
      subject
    end
  end

  describe '#edit' do
    after do
      get :edit
    end

    it 'should find all the projects' do
      project_scope = double.as_null_object
      project_scope.should_receive(:all)
      Project.should_receive(:order).with(:name).and_return(project_scope)
    end

    it 'should find all the aggregate projects' do
      AggregateProject.should_receive(:order).with(:name)
    end
  end
end
