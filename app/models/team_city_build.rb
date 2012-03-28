class TeamCityBuild < TeamCityRestProject

  attr_writer :build_status_fetcher, :build_type_fetcher

  def build_id
    feed_url.match(/id:([^)]*)/)[1]
  end

  def online?
    status.online? && children.all?(&:online?)
  end

  def success?
    green? && children.all?(&:green?)
  end

  def red?
    !green? || children.any?(&:red?)
  end

  def green?
    super && children.all?(&:green?)
  end

  def building?
    build_status.building? || children.any?(&:building?)
  end

  def status
    latest_status || live_status
  end

  def live_status
    ProjectStatus.new.tap do |s|
      s.online = build_status.online?
      s.success = build_status.green?
    end
  end

  def parse_project_status(*)
    live_status.tap do |s|
      s.published_at = publish_date
    end
  end

  def parse_building_status(*)
    build_status
  end

  def publish_date
    date = build_status.publish_date
    children.each do |child|
      if child.publish_date > date
        date = child.publish_date
      end
    end
    date
  end

  def children
    TeamCityChildBuilder.parse(self, build_type_fetcher.call)
  rescue Net::HTTPError
    []
  end

  private

  def build_status
    @build_status ||= build_status_fetcher.call
  end

  def build_status_fetcher
    @build_status_fetcher ||= proc { TeamCityBuildStatus.new self }
  end

  def build_type_fetcher
    @build_type_fetcher ||= proc {
      UrlRetriever.retrieve_content_at(build_type_url, auth_username, auth_password)
    }
  end

  def build_type_url
    uri = URI(feed_url)
    "#{uri.scheme}://#{uri.host}:#{uri.port}/httpAuth/app/rest/buildTypes/id:#{build_id}"
  end
end
