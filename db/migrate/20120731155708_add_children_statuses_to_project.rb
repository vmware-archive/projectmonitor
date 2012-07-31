class AddChildrenStatusesToProject < ActiveRecord::Migration
  def up
    change_table :projects do |t|
      t.column :has_failing_children, :boolean, null: false, default: false
      t.column :has_building_children, :boolean, null: false, default: false
    end
  end

  def down
    change_table :projects do |t|
      t.remove :has_failing_children
      t.remove :has_building_children
    end
  end
end
