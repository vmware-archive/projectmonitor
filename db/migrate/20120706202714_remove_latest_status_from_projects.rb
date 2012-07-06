class RemoveLatestStatusFromProjects < ActiveRecord::Migration

  #Renaming instead of deleting to preserve production data and observe this for a few days.
  def up
    rename_column :projects, :latest_status_id, :deprecated_latest_status_id
  end

  def down
    rename_column :projects, :deprecated_latest_status_id, :latest_status_id
  end
end
