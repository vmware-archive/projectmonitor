class RenameProjectStatusesIndexIfExists < ActiveRecord::Migration
  def self.up
    if index_exists?("project_statuses", [:project_id, :online, :published_at], :name => "index_project_statuses_on_project_id_and_online_and_published_at")
      rename_index "project_statuses", "index_project_statuses_on_project_id_and_online_and_published_at", "index_project_statuses_on_project_id_and_others"
    end
  end

  def self.down
    rename_index "project_statuses", "index_project_statuses_on_project_id_and_others", "index_project_statuses_on_project_id_and_online_and_published_at"
  end
end
