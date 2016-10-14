class AddTeamNameToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :team_name, :string
  end
end
