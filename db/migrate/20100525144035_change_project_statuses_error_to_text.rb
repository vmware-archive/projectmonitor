class ChangeProjectStatusesErrorToText < ActiveRecord::Migration
  def self.up
    change_column :project_statuses, :error, :text
  end

  def self.down
    change_column :project_statuses, :error, :string
  end
end
