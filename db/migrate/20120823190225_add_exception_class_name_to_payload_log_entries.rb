class AddExceptionClassNameToPayloadLogEntries < ActiveRecord::Migration
  def change
    add_column :payload_log_entries, :error_type, :string
  end
end
