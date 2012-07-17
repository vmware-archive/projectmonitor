class DropSerializedFeedUrlPartsFromProjects < ActiveRecord::Migration
  def up
    remove_column :projects, :serialized_feed_url_parts
  end

  def down
    add_column :projects, :serialized_feed_url_parts, :text
  end
end
