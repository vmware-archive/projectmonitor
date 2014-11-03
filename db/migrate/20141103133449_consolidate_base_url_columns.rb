class ConsolidateBaseUrlColumns < ActiveRecord::Migration
  
  @@old_columns = [
    'jenkins_base_url', 'concourse_base_url', 'team_city_base_url', 'team_city_rest_base_url'
  ]

  def up
    # New consolidation column
    add_column :projects, :ci_base_url, :string

    @@old_columns.each do |old_column|
      # Copy data across
      Project.where.not(old_column => nil).each do |project|
        project.update(ci_base_url: project[old_column])
      end

      # Prefix old columns with 'deprecated'
      rename_column :projects, old_column, "deprecated_#{old_column}"
    end
  end

  def down
    @@old_columns.each do |old_column|
      rename_column :projects, "deprecated_#{old_column}", old_column
    end

    remove_column :projects, :ci_base_url
  end
end
