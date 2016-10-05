class RenameConcourseToConcourseV1 < ActiveRecord::Migration
  def change
    execute <<-SQL
update projects set type = 'ConcourseV1Project' where type = 'ConcourseProject'
    SQL
  end
end
