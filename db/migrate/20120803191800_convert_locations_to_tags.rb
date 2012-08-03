class ConvertLocationsToTags < ActiveRecord::Migration
  Project = Class.new ActiveRecord::Base

  def up
    Project.where('location IS NOT NULL').find_each do |project|
      new_tag_list = (project.tag_list + [project.location.gsub(/\s+/, '_')]).uniq
      project.update_attributes(tag_list: new_tag_list)
    end
    rename_column :projects, :location, :deprecated_location
  end

  def down
    rename_column :projects, :deprecated_location, :location
  end
end
