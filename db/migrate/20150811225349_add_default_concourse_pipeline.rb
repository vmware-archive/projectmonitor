class AddDefaultConcoursePipeline < ActiveRecord::Migration
  def change
    execute <<-SQL
update projects set concourse_pipeline_name = 'main' where concourse_pipeline_name IS NULL and type = 'ConcourseProject'
    SQL
  end
end
