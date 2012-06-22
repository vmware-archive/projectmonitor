class ChangeTeamCityBuildToTeamCityChainedProject < ActiveRecord::Migration
  def up
    execute "UPDATE projects SET type='TeamCityChainedProject' WHERE type='TeamCityBuild'"
  end

  def down
    execute "UPDATE projects SET type='TeamCityBuild' WHERE type='TeamCityChainedProject'"
  end
end
