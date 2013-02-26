class AddFailuresCountToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :failures, :integer, default: 0
  end
end
