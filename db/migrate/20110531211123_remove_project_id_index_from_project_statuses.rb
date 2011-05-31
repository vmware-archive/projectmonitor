class RemoveProjectIdIndexFromProjectStatuses < ActiveRecord::Migration
  def self.up
    remove_index "project_statuses", "project_id"
  end

  def self.down
    add_index "project_statuses", "project_id"
  end
end
