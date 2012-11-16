class AddCodeClimateToProject < ActiveRecord::Migration
  def change
    add_column :projects, :code_climate_api_token, :string
    add_column :projects, :code_climate_repo_id, :string
    add_column :projects, :code_climate_gpa_current, :decimal, :precision => 8, :scale => 2
    add_column :projects, :code_climate_gpa_previous, :decimal, :precision => 8, :scale => 2
  end
end
