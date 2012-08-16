class AddSemaphoreProjectFieldsToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :semaphore_api_url, :string
  end
end
