class AddIndexingToPayloadLogEntriesCreatedAt < ActiveRecord::Migration
  def change
    add_index :payload_log_entries, :created_at
  end
end
