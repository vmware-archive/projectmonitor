class AddLatestStatusToProjects < ActiveRecord::Migration
  def self.up
    add_column "projects", "latest_status_id", :integer
    update <<-SQL
      UPDATE projects
      INNER JOIN (SELECT max(id) AS max_id, project_id FROM project_statuses GROUP BY project_id) t1
        ON t1.project_id = projects.id SET projects.latest_status_id = max_id
    SQL
  end

  def self.down
    remove_column "projects", "latest_status_id"
  end
end
