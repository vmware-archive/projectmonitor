class AddCreatorIdToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :creator_id, :integer, references: "users"
  end
end
