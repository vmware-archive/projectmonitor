require 'spec_helper'

describe ConfigExport do

  context 'given a full set of configuration records' do

    before do
      Project.destroy_all
      AggregateProject.destroy_all
    end

    it "should create new project when there is no guid" do
      FactoryGirl.create(:jenkins_project, name: 'Foo', tag_list: %w[foo bar baz])
      yaml = YAML.load(ConfigExport.export)
      yaml['projects'].first.delete('guid')

      expect do
        ConfigExport.import yaml.to_yaml
      end.to change(Project, :count).by(1)
    end

    it "should update the project when there is a guid" do
      jenkins_project = FactoryGirl.create(:jenkins_project, name: 'Foo', tag_list: %w[foo bar baz])
      yaml = YAML.load(ConfigExport.export)
      yaml['projects'].first['name']= 'New name'
      yaml['projects'].first['tag_list']= %w[a b c]

      ConfigExport.import yaml.to_yaml

      jenkins_project.reload.name.should == 'New name'
      jenkins_project.tag_list.should =~ %w[a b c]
    end

    context 'given an old configuration file with obsolete fields' do
      it 'should import the records' do
        expect do
          expect do
            ConfigExport.import File.read('spec/fixtures/files/old_configuration.yml')
          end.to change(AggregateProject, :count).by(1)
        end.to change(Project, :count).by(1)
      end
    end
  end
end
