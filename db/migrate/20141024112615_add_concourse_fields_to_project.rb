class AddConcourseFieldsToProject < ActiveRecord::Migration
  def change
    add_column :projects, :concourse_base_url, :string
    add_column :projects, :concourse_job_name, :string
  end
end
