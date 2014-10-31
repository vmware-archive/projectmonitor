class TravisProject < Project

  validates_presence_of :travis_github_account, :travis_repository, unless: ->(project) { project.webhooks_enabled }

  BASE_API_URL = "https://api.travis-ci.org"

  alias_attribute :build_status_url, :feed_url
  alias_attribute :project_name, :travis_github_account

  def self.project_specific_attributes
    super.reject do |column|
      column.start_with? "travis_pro_"
    end
  end

  def feed_url
    "#{base_url}/builds.json"
  end

  def has_status?(status)
    statuses.where(build_id: status.build_id, success: status.success).exists?
  end

  def fetch_payload
    TravisJsonPayload.new.tap do |payload|
      payload.slug = slug
      payload.branch = build_branch
    end
  end

  alias_method :webhook_payload, :fetch_payload

  def requires_branch_name?
    true
  end

  def slug
    "#{travis_github_account}/#{travis_repository}"
  end

  private

  def base_url
    "#{self.class.const_get(:BASE_API_URL)}/repositories/#{slug}"
  end
end
