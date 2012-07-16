class AddTrackerOnlineToProjects < ActiveRecord::Migration
  def up
    add_column :projects, :tracker_online, :boolean
    execute 'UPDATE projects SET tracker_online = TRUE WHERE current_velocity != 0'
  end

  def down
    remove_column :projects, :tracker_online
  end
end
