class RenameHudsonToJenkins < ActiveRecord::Migration
  def up
    execute <<-SQL
      UPDATE projects
      SET type = 'JenkinsProject'
      WHERE type = 'HudsonProject';
    SQL
  end

  def down
    execute <<-SQL
      UPDATE projects
      SET type = 'HudsonProject'
      WHERE type = 'JenkinsProject';
    SQL
  end
end
