class AddNotificationEmailToProject < ActiveRecord::Migration
  def change
    add_column :projects, :notification_email, :string
    add_column :projects, :send_build_notifications, :boolean
    add_column :projects, :send_error_notifications, :boolean
  end
end
