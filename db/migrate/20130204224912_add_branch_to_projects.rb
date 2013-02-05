class AddBranchToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :build_branch, :string
  end
end
