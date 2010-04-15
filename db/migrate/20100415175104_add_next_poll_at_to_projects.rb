class AddNextPollAtToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :next_poll_at, :datetime
  end

  def self.down
    remove_column :projects, :next_poll_at
  end
end
