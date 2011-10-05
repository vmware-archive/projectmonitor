class AddEc2InfoToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :ec2_access_key_id, :string
    add_column :projects, :ec2_secret_access_key, :string
    add_column :projects, :ec2_instance_id, :string

  end

  def self.down
    remove_column :projects, :ec2_access_key_id
    remove_column :projects, :ec2_secret_access_key
    remove_column :projects, :ec2_instance_id
  end
end
