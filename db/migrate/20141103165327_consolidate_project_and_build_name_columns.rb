class ConsolidateProjectAndBuildNameColumns < ActiveRecord::Migration
  @@old_columns = [
    'jenkins_build_name', 'team_city_build_id', 'team_city_rest_build_type_id',
    'tddium_project_name', 'circleci_project_name', 'concourse_job_name'
  ]

  def up
    # New consolidation column
    add_column :projects, :ci_build_name, :string

    @@old_columns.each do |old_column|
      # Copy data across
      Project.where.not(old_column => nil).each do |project|
        project.update(ci_build_name: project[old_column])
      end

      # Prefix old columns with 'deprecated'
      rename_column :projects, old_column, "deprecated_#{old_column}"
    end
  end

  def down
    @@old_columns.each do |old_column|
      rename_column :projects, "deprecated_#{old_column}", old_column
    end

    remove_column :projects, :ci_build_name
  end
end
