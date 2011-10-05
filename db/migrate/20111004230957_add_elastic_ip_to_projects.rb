class AddElasticIpToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :ec2_elastic_ip, :string
  end

  def self.down
    remove_column :projects, :ec2_elastic_ip
  end
end
