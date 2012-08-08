class AddGuidsToExistingProjects < ActiveRecord::Migration
  Project = Class.new ActiveRecord::Base

  def up
    Project.all.each do |project|
      project.send(:generate_guid)
      next unless project.save
    end
  end

  def down

  end
end
