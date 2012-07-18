class TeamCityPayloadProcessor < ProjectPayloadProcessor

  def fetch_new_statuses
    if detect_json?
      parse_status_as_json
    else
      build_live_statuses.each do |parsed_status|
        parsed_status.save! unless project.statuses.find_by_url(parsed_status.url)
      end
    end
  end

  def build_live_statuses
    live_status_hashes.map { |status_hash|
      ProjectStatus.new(
        :project => project,
        :online => true,
        :success => status_hash[:status] == 'SUCCESS',
        :url => status_hash[:url],
        :published_at => status_hash[:published_at],
      )
    }.sort { |status1, status2| status1.published_at <=> status2.published_at }
  end

  def parse_building_status
    (live_builds.present? && live_builds.first[:running])
  end

  def live_status_hashes
    live_builds.reject { |status|
      status[:status] == 'UNKNOWN' || (status[:running] && status[:status] == 'SUCCESS')
    }
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
    Nokogiri::XML.parse(payload).css('build').to_a.first(50)
  end

  def parse_start_date_attribute(start_date_attribute)
    if start_date_attribute.present?
      Time.parse(start_date_attribute.value).localtime
    else
      Time.now.localtime
    end
  end

  def parse_status_as_json
    status = project.statuses.new(:online => false, :success => false)
    status.build_id = payload["buildId"]
    status.published_at = Time.now
    status.success = payload["buildResult"] == "success"
    status.url = project.feed_url
    status.save!
  end

  def detect_json?
    if payload.respond_to?(:keys) && self.payload = payload["build"]
      payload.keys.select{|k| k.match(/buildStatus/)}.any? rescue false
    end
  end

end
