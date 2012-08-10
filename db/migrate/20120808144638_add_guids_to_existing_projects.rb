class AddGuidsToExistingProjects < ActiveRecord::Migration
  Project = Class.new ActiveRecord::Base
  TeamCityChainedProject = Class.new ActiveRecord::Base
  TeamCityProject = Class.new ActiveRecord::Base
  TeamCityRestProject = Class.new ActiveRecord::Base
  JenkinsProject = Class.new ActiveRecord::Base
  TravisProject = Class.new ActiveRecord::Base
  CruiseControlProject = Class.new ActiveRecord::Base

  def up
    Project.all.each do |project|
      project.send(:generate_guid)
      next unless project.save
    end
  end

  def down

  end
end
