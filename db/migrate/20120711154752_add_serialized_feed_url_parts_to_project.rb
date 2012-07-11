class AddSerializedFeedUrlPartsToProject < ActiveRecord::Migration
  def up
    add_column :projects, :serialized_feed_url_parts, :text
  end
  def down
    remove_column :projects, :serialized_feed_url_parts
  end
end
