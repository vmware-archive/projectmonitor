class AddIndexToProjectStatusesProjectId < ActiveRecord::Migration
  def self.up
    add_index :project_statuses, :project_id
  end

  def self.down
    drop_index :project_statuses, :project_id
  end
end
