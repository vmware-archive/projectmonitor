class FixtureFile
  def initialize(subdir, filename)
    @content = File.read(File.join(Rails.root, "spec", "fixtures", subdir, filename))
  end

  def read
    @content
  end

  def as_xml
    Nokogiri::XML(@content)
  end
end

class BuildingStatusExample < FixtureFile
  def initialize(filename)
    super("building_status_examples", filename)
  end
end

class CCRssExample < FixtureFile
  def initialize(filename)
    super("cc_rss_examples", filename)
  end

  def xpath_content(xpath)
    as_xml.at_xpath(xpath).content
  end
end

class TravisExample < FixtureFile
  def initialize(filename)
    super("travis_examples", filename)
  end

  def as_json
    JSON.parse(read)
  end
end

class JenkinsJsonExample < FixtureFile
  def initialize(filename)
    super("jenkins_json_examples", filename)
  end
end

class TeamCityJsonExample < FixtureFile
  def initialize(filename)
    super("teamcity_json_examples", filename)
  end
end

class JenkinsAtomExample < FixtureFile
  def initialize(filename)
    super("jenkins_atom_examples", filename)
  end

  def as_xml
    Nokogiri::XML.parse(read)
  end

  def first_css(selector)
    as_xml.at_css(selector)
  end
end

class TeamcityAtomExample < FixtureFile
  def initialize(filename)
    super("teamcity_atom_examples", filename)
  end
end

class TeamcityCradiatorXmlExample < FixtureFile
  def initialize(filename)
    super("teamcity_cradiator_xml_examples", filename)
  end

  def as_xml
    Nokogiri::XML.parse(read)
  end

  def first_css(selector)
    as_xml.at_css(selector)
  end
end

class TeamcityRESTExample < FixtureFile
  def initialize(filename)
    super("teamcity_rest_examples", filename)
  end

  def as_xml
    Nokogiri::XML.parse(read)
  end

  def first_css(selector)
    as_xml.at_css(selector)
  end
end
