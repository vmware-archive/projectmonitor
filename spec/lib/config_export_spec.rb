require 'spec_helper'

describe ConfigExport do

  context 'given a full set of configuration records' do
    let(:aggregate_project) { stub_model(AggregateProject, name: 'agg', id: 1, tag_list: [])}
    let(:solo_project) { FactoryGirl.create(:jenkins_project, name: 'Foo', tag_list: %w[foo bar baz]) }
    let(:aggregated_project) { FactoryGirl.build(:travis_project, name: 'Led', aggregate_project_id: 1) }
    let(:projects) do
      [solo_project, aggregated_project]
    end
    let(:aggregate_projects) { [aggregate_project] }

    before do
      aggregate_project.stub(:id).and_return(1)
      Project.stub(:all).and_return(projects)
      AggregateProject.stub(:all).and_return(aggregate_projects)
    end

    it 'can export and import those records' do
      expect do
        export = ConfigExport.export

        solo_project.name = Faker::Company.name
        solo_project.tag_list = nil
        solo_project.save!

        ConfigExport.import export
      end.to change(Project, :count).by(1)

      aggregate_project = AggregateProject.last
      aggregate_project.name.should == 'agg'

      solo_project.reload.name.should == 'Foo'
      solo_project.tag_list.should == %w[foo bar baz]

      aggregated_project = Project.last
      aggregated_project.name.should == 'Led'
      aggregated_project.aggregate_project_id.should == aggregate_project.id
    end
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
