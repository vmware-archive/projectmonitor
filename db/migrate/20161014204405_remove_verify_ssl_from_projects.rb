class RemoveVerifySslFromProjects < ActiveRecord::Migration
  def change
    remove_column :projects, :verify_ssl, :boolean
  end
end
