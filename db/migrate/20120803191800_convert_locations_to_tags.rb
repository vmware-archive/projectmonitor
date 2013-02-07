class ConvertLocationsToTags < ActiveRecord::Migration
  Project = Class.new ActiveRecord::Base do
    self.inheritance_column = nil
  end

  Tag = Class.new(ActiveRecord::Base)

  def up
    Project.where('location IS NOT NULL').find_each do |project|
      location_tag = Tag.find_or_create_by_name(project.location.gsub(/\s+/, '_'))
      ActiveRecord::Base.connection.
        execute("INSERT INTO taggings (tag_id, taggable_id, taggable_type) VALUES (#{location_tag.id}, #{project.id}, 'Project')")
    end
    rename_column :projects, :location, :deprecated_location
  end

  def down
    rename_column :projects, :deprecated_location, :location
  end
end
