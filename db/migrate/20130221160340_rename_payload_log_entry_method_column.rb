class RenamePayloadLogEntryMethodColumn < ActiveRecord::Migration
  def change
    rename_column :payload_log_entries, :method, :update_method
  end
end
