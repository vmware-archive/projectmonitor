class CreatePayloadLog < ActiveRecord::Migration
  def up
    create_table :payload_log_entries do |t|
      t.timestamps
      t.integer :project_id
      t.string :status
      t.string :method
      t.string :error_text
    end
  end

  def down
    drop_table :payload_log_entries
  end
end
