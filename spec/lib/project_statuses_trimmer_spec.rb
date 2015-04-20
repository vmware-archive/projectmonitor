
require 'spec_helper'

describe ProjectStatusesTrimmer do
  before do
    Project.delete_all
    ProjectStatus.delete_all
    for i in (1..4) do
      create(:project, id: i)
      (5*i).times do
        create(:project_status, project_id: i)
      end
    end
  end

  it 'reduces the number of project statuses to the newest N requested amount for each project' do
    subject.run(10)
    expect(ProjectStatus.count).to eq(35)
  end
end