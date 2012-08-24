class AddDependentProjectsToProject < ActiveRecord::Migration
  def up
    change_table :projects do |table|
      table.integer :parent_project_id
      table.remove :has_failing_children
      table.remove :has_building_children
    end
  end

  def down
    change_table :projects do |table|
      table.remove :parent_project_id
      table.boolean :has_failing_children, default: false, null: false
      table.boolean :has_building_children, default: false, null: false
    end
  end
end
