class AddProjectIdAndTrackerAuthTokenToProject < ActiveRecord::Migration
  def change
    add_column :projects, :tracker_project_id, :string, null: true
    add_column :projects, :tracker_auth_token, :string, null: true
  end
end
