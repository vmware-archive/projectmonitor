class RenameCiBuildNameToCiBuildIdentifier < ActiveRecord::Migration
  def change
    # Column can represent the following depending on CI: 'build id' / 'build name' / 'project name'
    rename_column :projects, :ci_build_name, :ci_build_identifier
  end
end
