class AddTrackerValidationStatusToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :tracker_validation_status, :string
  end
end
