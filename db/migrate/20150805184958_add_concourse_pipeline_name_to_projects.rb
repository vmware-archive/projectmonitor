class AddConcoursePipelineNameToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :concourse_pipeline_name, :string
  end
end
