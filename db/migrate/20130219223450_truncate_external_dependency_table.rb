class TruncateExternalDependencyTable < ActiveRecord::Migration
  def up
    execute("TRUNCATE TABLE external_dependencies;")
  end

  def down
  end
end
