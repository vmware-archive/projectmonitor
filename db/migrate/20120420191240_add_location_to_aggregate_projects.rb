class AddLocationToAggregateProjects < ActiveRecord::Migration
  def change
    add_column :aggregate_projects, :location, :string, :limit => 20
  end
end
