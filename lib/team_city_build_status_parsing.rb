module TeamCityBuildStatusParsing
  private

  def live_status_hashes
    statuses = status_nodes.map { |node| status_hash_for(node) }
    statuses.reject { |status|
      status[:status] == 'UNKNOWN' || (status[:running] && status[:status] == 'SUCCESS')
    }
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
