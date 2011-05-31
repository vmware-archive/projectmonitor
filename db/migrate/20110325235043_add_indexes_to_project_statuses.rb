class AddIndexesToProjectStatuses < ActiveRecord::Migration
  def self.up
    add_index :project_statuses, [:project_id, :online, :published_at], :name => 'index_project_statuses_on_project_id_and_others'
  end

  def self.down
    remove_index :project_statuses, :name => 'index_project_statuses_on_project_id_and_others'
  end
end
