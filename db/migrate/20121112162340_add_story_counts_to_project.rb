class AddStoryCountsToProject < ActiveRecord::Migration
  def change
    add_column :projects, :stories_to_accept_count, :integer
    add_column :projects, :open_stories_count, :integer
  end
end
