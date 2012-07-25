require 'spec_helper'

describe 'dashboards/_project' do

  let(:project) { ProjectDecorator.new(FactoryGirl.build(:cruise_control_project)) }
  subject { render :partial => 'dashboards/project', :locals => {:project => project, :tiles_count => 15} }

  it 'should have a heading with the project code' do
    subject
    rendered.should have_css(%{h1:contains("#{project.code}")})
  end

  context 'when the project has a status url' do
    let(:status_url) { 'http://localhost:3000' }
    before do
      project.stub(:status_url).and_return(status_url)
    end

    it 'should have a link to the project status page' do
      subject
      rendered.should have_css(%{h1:contains("#{project.code}") > a[href = "#{status_url}"]})
    end
  end

  context 'when the project does not have a status url' do
    it 'should have a heading with the project code' do
      subject
      rendered.should_not have_css(%{h1:contains("#{project.code}") > a})
    end
  end

end
