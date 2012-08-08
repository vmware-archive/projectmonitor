class AddGuidToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :guid, :string
  end
end
