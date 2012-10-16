class CreatePayloadLogEntriesIndex < ActiveRecord::Migration
  def up
    add_index :payload_log_entries, [:project_id, :created_at]
  end

  def down
    remove_index :payload_log_entries, :column => [:project_id, :created_at]
  end
end
