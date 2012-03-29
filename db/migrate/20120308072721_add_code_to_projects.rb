class AddCodeToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :code, :string
    add_column :aggregate_projects, :code, :string
  end
end
