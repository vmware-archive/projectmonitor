class AddOnlineToProject < ActiveRecord::Migration
  def change
    add_column :projects, :online, :boolean, default: false
    remove_column :project_statuses, :online
  end
end
