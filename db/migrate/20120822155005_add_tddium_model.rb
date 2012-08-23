class AddTddiumModel < ActiveRecord::Migration
  def change
    add_column :projects, :tddium_auth_token, :string
    add_column :projects, :tddium_project_name, :string
  end
end
