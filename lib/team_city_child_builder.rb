class TeamCityChildBuilder

  def self.parse(parent, content)
    new(parent, content).build
  end

  def initialize(parent, content)
    @parent = parent
    @content = content
  end

  def build
    child_build_ids = parsed_content.xpath("//snapshot-dependency").collect {|d| d.attributes["id"].to_s }

    child_build_ids.map { |child_id| build_project(child_id) }
  end

  private

  def build_project(build_id)
    TeamCityChildProject.new(
      :build_id => build_id,
      :feed_url => @parent.feed_url.gsub(@parent.build_id, build_id),
      :auth_username => @parent.auth_username,
      :auth_password => @parent.auth_password
    )
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
