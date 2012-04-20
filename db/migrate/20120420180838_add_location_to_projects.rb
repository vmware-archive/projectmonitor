class AddLocationToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :location, :string, limit: 20
  end
end
