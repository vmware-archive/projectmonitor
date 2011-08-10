class AddScheduleToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :ec2_monday, :boolean
    add_column :projects, :ec2_tuesday, :boolean
    add_column :projects, :ec2_wednesday, :boolean
    add_column :projects, :ec2_thursday, :boolean
    add_column :projects, :ec2_friday, :boolean
    add_column :projects, :ec2_saturday, :boolean
    add_column :projects, :ec2_sunday, :boolean

    add_column :projects, :ec2_start_time, :time
    add_column :projects, :ec2_end_time, :time
  end

  def self.down
    remove_column :projects, :ec2_monday
    remove_column :projects, :ec2_tuesday
    remove_column :projects, :ec2_wednesday
    remove_column :projects, :ec2_thursday
    remove_column :projects, :ec2_friday
    remove_column :projects, :ec2_saturday
    remove_column :projects, :ec2_sunday

    remove_column :projects, :ec2_start_time
    remove_column :projects, :ec2_end_time
  end
end
