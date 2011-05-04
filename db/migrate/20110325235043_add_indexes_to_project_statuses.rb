class AddIndexesToProjectStatuses < ActiveRecord::Migration
  def self.up
    add_index :project_statuses, [:project_id, :online, :published_at]
  end

  def self.down
    remove_index :project_statuses, [:project_id, :online, :published_at]
  end
end
