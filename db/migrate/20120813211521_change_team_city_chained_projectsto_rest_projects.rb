class ChangeTeamCityChainedProjectstoRestProjects < ActiveRecord::Migration
  def up
    execute <<-SQL
        UPDATE projects set type = "TeamCityRestProject" where type = "TeamCityChainedProject";
    SQL
  end

  def down

  end
end
