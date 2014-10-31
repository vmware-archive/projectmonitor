require 'spec_helper'

describe ConfigurationController, :type => :controller do
  before { sign_in create(:user) }

  describe '#index' do
    subject { get :show }

    it 'should return the configuration' do
      expect(ConfigExport).to receive(:export)
      subject
    end
  end

  describe '#create' do
    subject do
      post :create, content: fixture_file_upload('/files/empty_configuration.yml')
    end

    it 'should change the configuration' do
      expect(ConfigExport).to receive(:import).with("---\naggregated_projects: []\nprojects: []\n")
      subject
    end
  end

  describe '#edit' do
    let(:tags) { 'nyc' }

    it 'should find all the projects' do
      project_scope = double.as_null_object
      expect(Project).to receive(:order).with(:name).and_return(project_scope)
      get :edit, tags: tags
    end

    it 'should find all the aggregate projects' do
      aggregate_scope = double
      expect(AggregateProject).to receive(:order).with(:name).and_return(aggregate_scope)
      get :edit, tags: tags
    end

    it 'gets a list of all the tags in the system' do
      tag_list = [ double(:tag, name: 'nyc') ]
      expect(ActsAsTaggableOn::Tag).to receive(:order).with(:name).and_return tag_list
      get :edit, tags: tags
      expect(assigns(:tags)).to eq(['nyc'])
    end
  end
end
