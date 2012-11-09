class AddProjectTimestamps < ActiveRecord::Migration
  change_table :projects do |t|
    t.timestamps
  end
end
