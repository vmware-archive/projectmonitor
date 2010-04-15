class AddPollingIntervalToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :polling_interval, :integer
  end

  def self.down
    remove_column :projects, :polling_interval
  end
end
