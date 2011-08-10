class AddScheduleToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :monday, :boolean
    add_column :projects, :tuesday, :boolean
    add_column :projects, :wednesday, :boolean
    add_column :projects, :thursday, :boolean
    add_column :projects, :friday, :boolean
    add_column :projects, :saturday, :boolean
    add_column :projects, :sunday, :boolean

    add_column :projects, :start_time, :time
    add_column :projects, :end_time, :time
  end

  def self.down
    remove_column :projects, :monday
    remove_column :projects, :tuesday
    remove_column :projects, :wednesday
    remove_column :projects, :thursday
    remove_column :projects, :friday
    remove_column :projects, :saturday
    remove_column :projects, :sunday

    remove_column :projects, :start_time
    remove_column :projects, :end_time
  end
end
