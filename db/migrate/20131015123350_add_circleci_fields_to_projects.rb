class AddCircleciFieldsToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :circleci_auth_token, :string
    add_column :projects, :circleci_project_name, :string
    add_column :projects, :circleci_username, :string
  end
end
