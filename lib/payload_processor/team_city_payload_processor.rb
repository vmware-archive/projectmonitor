class TeamCityPayloadProcessor < ProjectPayloadProcessor

  def fetch_new_statuses
    if detect_json?
      parse_project_status_from_json
    else
      parse_project_status
    end
  end

  def parse_project_status
    build_live_statuses.each do |parsed_status|
      parsed_status.save! unless project.statuses.find_by_url(parsed_status.url)
      project.online!
    end
  end

  def build_live_statuses
    live_status_hashes.map { |status_hash|
      ProjectStatus.new(
        :project => project,
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

  def parse_project_status_from_json
    status = project.statuses.new(:success => false)
    case payload["buildResult"]
    when "success"
      status.success = true
    when "failure"
      status.success = false
    else
      return
    end
    status.build_id = payload["buildId"]
    status.published_at = Time.now
    status.url = project.feed_url
    status.save!
  end

  def parse_building_status_from_json
    payload["buildResult"] == "running" && payload["notifyType"] == "buildStarted"
  end

  def detect_json?
    if payload.respond_to?(:keys) && self.payload = payload.fetch("build", payload)
      payload.keys.select{|k| k.match(/buildStatus/)}.any? rescue false
    end
  end

end
