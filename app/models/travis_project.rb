class TravisProject < Project

  attr_accessible :travis_github_account, :travis_repository
  validates_presence_of :travis_github_account, :travis_repository, unless: ->(project) { project.webhooks_enabled }

  def feed_url
    "#{base_url}/builds.json"
  end

  def build_status_url
    feed_url
  end

  def status_url
    base_url
  end

  def project_name
    travis_github_account
  end

  def fetch_payload
    TravisJsonPayload.new
  end

  def webhook_payload
    TravisJsonPayload.new
  end

  private

  def base_url
    "http://travis-ci.org/#{travis_github_account}/#{travis_repository}"
  end

end
