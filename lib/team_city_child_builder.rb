class TeamCityChildBuilder

  def self.parse(parent, content)
    new(parent, content).build
  end

  def initialize(parent, content)
    @parent = parent
    @content = content
  end

  def build
    dependencies
  end

  private

  def build_project(build_id)
    TeamCityBuild.new(
      :feed_url => @parent.feed_url.gsub(@parent.build_id, build_id),
      :auth_username => @parent.auth_username,
      :auth_password => @parent.auth_password
    )
  end

  def dependencies
    parsed_content.xpath("//snapshot-dependency").collect {|d| d.attributes["id"].to_s }.map do |id|
      build_project id
    end
  end

  def parsed_content
    @parsed_content ||= Nokogiri::XML(@content)
  end

  def base_url
    @base_url ||= "#{root_url.scheme}://#{root_url.host}:#{root_url.port}"
  end

  def root_url
    @root_url ||= URI(parsed_content.xpath("//buildType").first.attributes["webUrl"].to_s)
  end
end
