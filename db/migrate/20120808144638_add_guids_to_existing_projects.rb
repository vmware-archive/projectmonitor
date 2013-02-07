require "securerandom"

class AddGuidsToExistingProjects < ActiveRecord::Migration
  Project = Class.new ActiveRecord::Base do
    self.inheritance_column = nil
  end

  def up
    Project.all.each do |project|
      project.guid = SecureRandom.uuid
      next unless project.save
    end
  end

  def down

  end
end
