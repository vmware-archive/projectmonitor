class AddLatestStatusToProjects < ActiveRecord::Migration
  def self.up
    add_column "projects", "latest_status_id", :integer
    latest_status_ids = select_rows "SELECT max(id) AS max_id, project_id FROM project_statuses GROUP BY project_id"
    latest_status_ids.each do |status_id, project_id|
      update "UPDATE projects SET latest_status_id = #{status_id} WHERE id = #{project_id}"
    end
  end

  def self.down
    remove_column "projects", "latest_status_id"
  end
end
