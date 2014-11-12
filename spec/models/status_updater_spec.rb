require 'spec_helper'

describe StatusUpdater, :type => :model do
  describe 'updating a project' do
    it 'pushes the status on the project' do
      status_updater = StatusUpdater.new
      project = Project.new
      status = ProjectStatus.new
      status_updater.update_project(project, status)

      expect(project.statuses).to include(status)
    end

    it 'removes older statuses beyond the max_status count' do
      status_updater = StatusUpdater.new(max_status: 3)
      project = create(:project)

      old_statuses = create_list(:project_status, 3)
      old_statuses.each { |old_status| status_updater.update_project(project, old_status) }
      oldest_status = old_statuses.first

      status = create(:project_status)
      status_updater.update_project(project, status)

      project.reload

      expect(project.statuses.count).to eq(3)
      expect(project.statuses.last).to eq(status)
      expect(project.statuses).to_not include(oldest_status)
    end
  end
end
