class FixtureFile
  def self.new(subdir, filename)
    File.read(File.join(Rails.root, "spec", "fixtures", subdir, filename))
  end
end

class BuildingStatusExample
  def self.new(filename)
    FixtureFile.new("building_status_examples", filename)
  end
end

class CCRssExample
  def self.new(filename)
    FixtureFile.new("cc_rss_examples", filename)
  end
end

class HudsonAtomExample
  def self.new(filename)
    FixtureFile.new("hudson_atom_examples", filename)
  end
end

class TeamcityAtomExample
  def self.new(filename)
    FixtureFile.new("teamcity_atom_examples", filename)
  end
end

class TeamcityCradiatorXmlExample
  def self.new(filename)
    FixtureFile.new("teamcity_cradiator_xml_examples", filename)
  end
end
