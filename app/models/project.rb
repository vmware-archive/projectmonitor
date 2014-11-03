class Project < ActiveRecord::Base

  RECENT_STATUS_COUNT = 8
  DEFAULT_POLLING_INTERVAL = 30
  MAX_STATUS = 15

  has_many :statuses,
    class_name: 'ProjectStatus',
    dependent: :destroy,
    before_add: :update_refreshed_at

  has_many :payload_log_entries
  belongs_to :aggregate_project
  belongs_to :creator, class_name: "User"

  serialize :last_ten_velocities, Array
  serialize :iteration_story_state_counts, JSON
  serialize :tracker_validation_status, Hash

  scope :enabled, -> { where(enabled: true) }
  scope :standalone, -> { where(aggregate_project_id: nil) }
  scope :with_statuses, -> { joins(:statuses).uniq }

  scope :updateable, -> {
    enabled.where(webhooks_enabled: [nil, false])
  }

  scope :tracker_updateable, -> {
    enabled
    .where.not(tracker_auth_token: [nil, ''])
    .where.not(tracker_project_id: [nil, ''])
  }

  scope :displayable, lambda { |tags|
    scope = enabled.order('code ASC')
    return scope.tagged_with(tags, any: true) if tags
    scope
  }

  acts_as_taggable

  validates :name, presence: true
  validates :type, presence: true

  before_create :generate_guid
  before_create :populate_iteration_story_state_counts

  before_save :trim_urls_and_tokens

  attr_writer :feed_url

  delegate :success?, :indeterminate?, :failure?, :color, to: :state

  alias_attribute :jenkins_base_url, :ci_base_url
  alias_attribute :concourse_base_url, :ci_base_url
  alias_attribute :team_city_base_url, :ci_base_url
  alias_attribute :team_city_rest_base_url, :ci_base_url

  def populate_iteration_story_state_counts
    self.iteration_story_state_counts = []
  end

  def self.project_specific_attributes
    columns.map(&:name).grep(/^#{project_attribute_prefix}_/)
  end

  def self.with_aggregate_project(aggregate_project_id, &block)
    where(aggregate_project_id: aggregate_project_id).scoping(&block)
  end

  def code
    super.presence || name.downcase.gsub(" ", '')[0..3]
  end

  def latest_status
    statuses.latest
  end

  def recent_statuses
    statuses.recent.limit(RECENT_STATUS_COUNT)
  end

  def status
    latest_status || ProjectStatus.new(project: self)
  end

  def requires_branch_name?
    false
  end

  def red_since
    breaking_build.try(:published_at)
  end

  def red_build_count
    return 0 if breaking_build.nil? || !online?
    statuses.red.where("id >= ?", breaking_build.id).count
  end

  def feed_url
    raise NotImplementedError, "Must implement feed_url in subclasses"
  end

  def build_status_url
    raise NotImplementedError, "Must implement build_status_url in subclasses"
  end

  def tracker_project_url
    "https://www.pivotaltracker.com/services/v3/projects/#{tracker_project_id}"
  end

  def tracker_iterations_url
    "https://www.pivotaltracker.com/services/v3/projects/#{tracker_project_id}/iterations/done?offset=-10"
  end

  def tracker_current_iteration_url
    "https://www.pivotaltracker.com/services/v3/projects/#{tracker_project_id}/iterations/current"
  end

  def to_s
    name
  end

  def last_green
    @last_green ||= recent_statuses.green.first
  end

  def breaking_build
    @breaking_build ||= if last_green.nil?
                          recent_statuses.red.last
                        else
                          recent_statuses.red.where("build_id > ?", last_green.build_id).first
                        end
  end

  def has_auth?
    auth_username.present? || auth_password.present?
  end

  def tracker_project?
    tracker_project_id.present? && tracker_auth_token.present?
  end
  alias tracker_configured?  tracker_project?

  def payload
    raise NotImplementedError, "Must implement payload in subclasses"
  end

  def has_status?(status)
    statuses.where(build_id: status.build_id).any?
  end

  def has_dependencies?
    false
  end

  def generate_guid
    self.guid = SecureRandom.uuid
  end

  def volatility
    @volatility ||= Volatility.calculate(last_ten_velocities)
  end

  def published_at
    latest_status.try(:published_at)
  end

  def accept_mime_types
    nil
  end

  def state
    State.new(online: online, success: latest_status.try(:success?))
  end

  # FIXME: This method shouldn't be a method of Project class
  def url_with_scheme(url)
    url =~ %r{\Ahttps?://} ? url : "http://#{url}"
  end

  def self.project_attribute_prefix
    name.match(/(.*)Project/)[1].underscore
  end

  private

  def trim_urls_and_tokens
    self.class.columns.select{|column| column.name.end_with?('_url', '_token') }.each do |column|
      write_attribute(column.name, read_attribute(column.name).try(:strip))
    end
  end

  def update_refreshed_at(status)
    self.last_refreshed_at = Time.now if online?
  end

  def fetch_statuses
    Delayed::Job.enqueue(StatusFetcher::Job.new(self), priority: 0)
  end
end
