class ProjectsHaveNoDefaultType < ActiveRecord::Migration
  def up
    change_column :projects, :type, :string, null: true
    change_column_default :projects, :type, nil
  end

  def down
    change_column :projects, :type, :string, null: false
    change_column_default :projects, :type, "CruiseControlProject"
  end
end
