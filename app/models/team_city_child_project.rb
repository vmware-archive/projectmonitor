class TeamCityChildProject
  include TeamCityProjectWithChildren
  attr_accessor :feed_url, :auth_username, :auth_password, :build_id

  def initialize(opts)
    opts.each do |attr,value|
      self.public_send("#{attr}=", value)
    end
  end

  def building?
    live_building_status.building? || children.any?(&:building?)
  end

  def red?
   live_status_hash[:status] != 'SUCCESS' || children.any?(&:red?)
  end

  def last_build_time
    [live_status_hash[:published_at], *children.map(&:last_build_time)].max
  end

  def self.feed_url_fields
    ["URL","ID"]
  end

  def processor
    TeamCityPayloadProcessor
  end

  def live_status_hash
    @live_status_hash ||= live_status_hashes.first
  end

  private
  def live_status_hashes
    live_builds.reject { |status|
      status[:status] == 'UNKNOWN' || (status[:running] && status[:status] == 'SUCCESS')
    }
  end

  def live_building_status
    most_recent_build = live_builds.first
    BuildingStatus.new( most_recent_build ? most_recent_build[:running] : false )
  end

  def live_builds
    status_nodes.map { |node| status_hash_for(node) }
  end

  def status_hash_for(node)
    {
      running: node.attribute('running').present?,
      status: node.attribute('status').value,
      url: node.attribute('webUrl').value,
      published_at: parse_start_date_attribute(node.attribute('startDate'))
    }
  end

  def status_nodes
    xml_text = UrlRetriever.retrieve_content_at(feed_url, auth_username, auth_password)
    Nokogiri::XML.parse(xml_text).css('build').to_a.first(50)
  end

  def parse_start_date_attribute(start_date_attribute)
    if start_date_attribute.present?
      Time.parse(start_date_attribute.value).localtime
    else
      Clock.now.localtime
    end
  end
end
