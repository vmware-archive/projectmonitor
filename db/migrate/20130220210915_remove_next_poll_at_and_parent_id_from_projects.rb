class RemoveNextPollAtAndParentIdFromProjects < ActiveRecord::Migration
  def up
    change_table(:projects) do |t|
      t.remove :next_poll_at
      t.remove :polling_interval
      t.remove :has_failing_children
      t.remove :has_building_children
    end
  end

  def down
    change_table(:projects) do |t|
      t.integer  "polling_interval"
      t.datetime "next_poll_at"
      t.boolean  "has_failing_children",                       :default => false, :null => false
      t.boolean  "has_building_children",                      :default => false, :null => false
    end
  end
end
