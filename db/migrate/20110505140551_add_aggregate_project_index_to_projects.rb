class AddAggregateProjectIndexToProjects < ActiveRecord::Migration
  def self.up
    add_index :projects, :aggregate_project_id
  end

  def self.down
    remove_index :projects, :aggregate_project_id
  end
end
