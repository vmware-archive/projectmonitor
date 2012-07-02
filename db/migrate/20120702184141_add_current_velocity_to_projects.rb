class AddCurrentVelocityToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :current_velocity, :integer, default: 0, null: false
  end
end
