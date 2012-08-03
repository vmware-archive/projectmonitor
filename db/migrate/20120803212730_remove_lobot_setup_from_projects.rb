class RemoveLobotSetupFromProjects < ActiveRecord::Migration
  def up
    change_table :projects do |t|
      t.remove  :ec2_monday
      t.remove  :ec2_tuesday
      t.remove  :ec2_wednesday
      t.remove  :ec2_thursday
      t.remove  :ec2_friday
      t.remove  :ec2_saturday
      t.remove  :ec2_sunday
      t.remove  :ec2_start_time
      t.remove  :ec2_end_time
      t.remove  :ec2_access_key_id
      t.remove  :ec2_secret_access_key
      t.remove  :ec2_instance_id
      t.remove  :ec2_elastic_ip
    end
  end

  def down
    change_table :projects do |t|
      t.boolean  :ec2_monday
      t.boolean  :ec2_tuesday
      t.boolean  :ec2_wednesday
      t.boolean  :ec2_thursday
      t.boolean  :ec2_friday
      t.boolean  :ec2_saturday
      t.boolean  :ec2_sunday
      t.time     :ec2_start_time
      t.time     :ec2_end_time
      t.string   :ec2_access_key_id
      t.string   :ec2_secret_access_key
      t.string   :ec2_instance_id
      t.string   :ec2_elastic_ip
    end
  end

end
