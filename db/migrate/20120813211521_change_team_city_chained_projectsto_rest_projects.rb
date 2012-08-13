class ChangeTeamCityChainedProjectstoRestProjects < ActiveRecord::Migration
  Project = Class.new ActiveRecord::Base do
    self.inheritance_column = nil
  end

  def up
    Project.where(type: "TeamCityChainedProject").update_all(type: "TeamCityRestProject")
  end

  def down

  end
end
