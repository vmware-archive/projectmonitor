class TravisProject < Project

  validates_format_of :feed_url,
    :with => %r(^https?://travis-ci.org/[\w-]+/[\w-]+/builds\.json$),
    :message => "should look like: http://travis-ci.org/[account]/[project]/builds.json"

  def project_name
    return nil if feed_url.nil?
    feed_url.split("/").last(2).first
  end

  def build_status_url
    feed_url
  end

  def self.feed_url_fields
    ["Account","Project"]
  end

  def self.build_url_from_fields(params)
    "http://travis-ci.org/#{params["Account"]}/#{params["Project"]}/builds.json"
  end

  def processor
    TravisPayloadProcessor
  end
end
