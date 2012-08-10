require "securerandom"

class Project < ActiveRecord::Base
end
class TeamCityChainedProject < Project
end
class TeamCityProject < Project
end
class TeamCityRestProject < Project
end
class JenkinsProject < Project
end
class TravisProject < Project
end
class CruiseControlProject < Project
end

class AddGuidsToExistingProjects < ActiveRecord::Migration
  def up
    Project.all.each do |project|
      project.guid = SecureRandom.uuid
      next unless project.save
    end
  end

  def down

  end
end
