class CreateAggregateProjects < ActiveRecord::Migration
  def self.up
    create_table :aggregate_projects do |t|
      t.string :name
      t.boolean :enabled, :default => true
      t.timestamps
    end

    add_column :projects, :aggregate_project_id, :integer
  end

  def self.down
    remove_column :projects, :aggregate_project_id
    drop_table :aggregate_projects
  end
end
