class AddBuildIdToProjectStatuses < ActiveRecord::Migration
  def change
    add_column :project_statuses, :build_id, :integer
  end
end
