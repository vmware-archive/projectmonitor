class Project < ActiveRecord::Base

  RECENT_STATUS_COUNT = 8
  DEFAULT_POLLING_INTERVAL = 30

  has_many :statuses,
    class_name: 'ProjectStatus',
    dependent: :destroy,
    before_add: :update_refreshed_at
  has_many :payload_log_entries
  has_many :dependent_projects,
    class_name: 'Project',
    foreign_key: :parent_project_id
  belongs_to :parent_project, class_name: "Project"
  belongs_to :aggregate_project

  serialize :last_ten_velocities, Array
  serialize :tracker_validation_status, Hash

  scope :enabled, where(enabled: true)
  scope :primary, where(parent_project_id: nil)
  scope :standalone, where(aggregate_project_id: nil)
  scope :with_statuses, joins(:statuses).uniq

  scope :updateable,
    enabled
      .where(webhooks_enabled: [nil, false])
      .where(['next_poll_at IS NULL OR next_poll_at <= ?', Time.now])

  scope :tracker_updateable,
    enabled.primary
      .where('tracker_auth_token is NOT NULL and tracker_project_id is NOT NULL')

  scope :displayable, lambda {|tags|
    scope = primary.enabled
    return scope.find_tagged_with(tags) if tags
    scope
  }

  acts_as_taggable

  validates :name, presence: true
  validates :type, presence: true

  before_save :check_next_poll
  before_create :generate_guid

  attr_accessible :aggregate_project_id,
    :code, :name, :enabled, :polling_interval, :type, :tag_list, :online, :building,
    :auth_password, :auth_username, :tracker_auth_token, :tracker_project_id, :tracker_online,
    :webhooks_enabled, :notification_email, :send_error_notifications, :send_build_notifications

  def self.project_specific_attributes
    columns.map(&:name).grep(/#{project_attribute_prefix}_/)
  end

  def self.with_aggregate_project aggregate_project_id, &block
    with_scope(find: where(aggregate_project_id: aggregate_project_id), &block)
  end

  def self.mark_for_immediate_poll
    update_all(next_poll_at: nil)
  end

  def check_next_poll
    set_next_poll if changed.include?('polling_interval')
  end

  def code
    super.presence || name.downcase.gsub(" ", '')[0..3]
  end

  def latest_status
    statuses.latest
  end

  def recent_statuses(count = RECENT_STATUS_COUNT)
    ProjectStatus.recent(self, count)
  end

  def status
    latest_status || ProjectStatus.new
  end

  def green?
    online? && status.success?
  end

  def yellow?
    online? && !red? && !green?
  end

  def red?
    online? && latest_status.try(:success?) == false || dependent_projects.any?(&:red?)
  end

  def color
    return "white" unless online?
    return "green" if green?
    return "red" if red?
    return "yellow" if yellow?
  end

  def tracker_configured?
    tracker_project_id.present? && tracker_auth_token.present?
  end

  def red_since
    breaking_build.try(:published_at)
  end

  def red_build_count
    return 0 if breaking_build.nil? || !online?
    statuses.count(:conditions => ["id >= ?", breaking_build.id])
  end

  def feed_url
    raise NotImplementedError, "Must implement feed_url in subclasses"
  end

  def build_status_url
  end

  def tracker_project_url
    "https://www.pivotaltracker.com/services/v3/projects/#{tracker_project_id}"
  end

  def tracker_iterations_url
    "https://www.pivotaltracker.com/services/v3/projects/#{tracker_project_id}/iterations/done?offset=-10"
  end

  def tracker_current_iteration_url
    "https://www.pivotaltracker.com/services/v3/projects/#{tracker_project_id}/iterations/current_backlog"
  end

  def to_s
    name
  end

  def set_next_poll
    self.next_poll_at = Time.now + (polling_interval || Project::DEFAULT_POLLING_INTERVAL)
  end

  def building?
    super || dependent_projects.any?(&:building?)
  end

  def current_build_url
  end

  def last_green
    @last_green ||= recent_statuses.green.first
  end

  def breaking_build
    @breaking_build ||= if last_green.nil?
      recent_statuses.red.last
    else
      recent_statuses.red.where(["build_id > ?", last_green.build_id]).first
    end
  end

  def has_auth?
    auth_username.present? || auth_password.present?
  end

  def tracker_project?
    tracker_project_id.present? && tracker_auth_token.present?
  end

  def payload
    raise NotImplementedError, "Must implement payload in subclasses"
  end

  def to_partial_path
    "dashboards/project"
  end

  def has_status?(status)
    statuses.where(build_id: status.build_id).any?
  end

  def has_dependent_project?(project)
    false
  end

  def has_dependencies?
    false
  end

  def dependent_build_info_url
  end

  def generate_guid
    self.guid = SecureRandom.uuid
  end

  def handler
    ProjectWorkloadHandler.new(self)
  end

  private

  def self.project_attribute_prefix
    name.match(/(.*)Project/)[1].underscore
  end

  def update_refreshed_at(status)
    self.last_refreshed_at = Time.now if online?
  end

end
