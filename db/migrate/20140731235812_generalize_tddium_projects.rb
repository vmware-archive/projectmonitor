class GeneralizeTddiumProjects < ActiveRecord::Migration
  def up
    change_table :projects do |t|
      t.column :tddium_base_url, :string
    end

    update "UPDATE projects SET tddium_base_url='https://api.tddium.com' WHERE type='TddiumProject'"
  end

  def down
    change_table :projects do |t|
      t.remove :tddium_base_url
    end
  end
end
