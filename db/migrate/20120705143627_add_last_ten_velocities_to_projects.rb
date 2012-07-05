class AddLastTenVelocitiesToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :last_ten_velocities, :string
  end
end
