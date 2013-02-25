class RemoveEmailFromProjects < ActiveRecord::Migration
  def up
    remove_column :projects, :send_build_notifications
    remove_column :projects, :send_error_notifications
  end

  def down
    change_table :projects do |t|
      t.boolean  "send_build_notifications"
      t.boolean  "send_error_notifications"
    end
  end
end
