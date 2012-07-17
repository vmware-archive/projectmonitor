class TravisProject < Project
  FEED_URL_REGEXP = %r{^https?://travis-ci.org/([\w-]*)/([\w-]*)/builds\.json$}

  validates :account, :project, :presence => true

  attr_accessible :account, :project

  def account
    feed_url =~ FEED_URL_REGEXP
    $1
  end
  
  def account=(account)
    self.feed_url = "http://travis-ci.org/#{account}/#{project}/builds.json"
  end

  def project
    feed_url =~ FEED_URL_REGEXP
    $2
  end

  def project=(project)
    self.feed_url = "http://travis-ci.org/#{account}/#{project}/builds.json"
  end

  def project_name
    return nil if feed_url.nil?
    feed_url.split("/").last(2).first
  end

  def build_status_url
    feed_url
  end

  def self.feed_url_fields
    ["Account", "Project"]
  end

  def processor
    TravisPayloadProcessor
  end
end
