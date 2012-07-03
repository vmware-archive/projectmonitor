class RemoveTrackerHealthFromProjects < ActiveRecord::Migration
  def up
    remove_column :projects, :tracker_num_unaccepted_stories
    remove_column :projects, :tracker_volatility
  end

  def down
    add_column :projects, :tracker_volatility,                           :default => 0,     :null => false
    add_column :projects, :tracker_num_unaccepted_stories,               :default => 0,     :null => false
  end
end
