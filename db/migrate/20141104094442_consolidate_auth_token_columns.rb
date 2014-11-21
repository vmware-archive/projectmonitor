class ConsolidateAuthTokenColumns < ActiveRecord::Migration
  @@old_columns = ['tddium_auth_token', 'circleci_auth_token', 'travis_pro_token']

  def up
    # New consolidation column
    add_column :projects, :ci_auth_token, :string

    @@old_columns.each do |old_column|
      # Copy data across
      Project.where.not(old_column => nil).each do |project|
        project.update_attribute(:ci_auth_token, project[old_column])
      end

      # Prefix old columns with 'deprecated'
      rename_column :projects, old_column, "deprecated_#{old_column}"
    end
  end

  def down
    @@old_columns.each do |old_column|
      rename_column :projects, "deprecated_#{old_column}", old_column
    end

    remove_column :projects, :ci_auth_token
  end
end
