class Project < ActiveRecord::Base
  RECENT_STATUS_COUNT = 8
  DEFAULT_POLLING_INTERVAL = 30

  has_many :statuses, :class_name => "ProjectStatus", :dependent => :destroy
  belongs_to :aggregate_project

  serialize :last_ten_velocities, Array

  scope :enabled, where(:enabled => true)
  scope :standalone, enabled.where(:aggregate_project_id => nil)
  scope :with_statuses, joins(:statuses).uniq
  scope :for_location, lambda { |location| where(location: location) }
  scope :unknown_location, where("location IS NULL OR location = ''")

  acts_as_taggable

  validates :name, presence: true
  validates :type, presence: true
  validates_length_of :location, :maximum => 20, :allow_blank => true

  before_save :check_next_poll
  after_create :fetch_statuses

  attr_accessible :aggregate_project_id,
    :code, :location, :name, :enabled, :polling_interval, :type, :tag_list, :online, :building,
    :auth_password, :auth_username,
    :tracker_auth_token, :tracker_project_id,
    :ec2_monday, :ec2_tuesday, :ec2_wednesday, :ec2_thursday, :ec2_friday, :ec2_saturday, :ec2_sunday,
    :ec2_elastic_ip, :ec2_instance_id, :ec2_secret_access_key, :ec2_access_key_id, :ec2_start_time, :ec2_end_time

  def self.displayable tags = nil
    scope = standalone.enabled
    return scope.find_tagged_with(tags) if tags
    scope
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

  def red?
    online? && !status.success?
  end

  def offline!
    update_attributes!(online: false) if online?
  end

  def online!
    update_attributes!(online: true) unless online?
  end

  def building!
    update_attributes!(building: true) unless building?
  end

  def not_building!
    update_attributes!(building: false) if building?
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
    raise NotImplementedError, "Must implement build_status_url in subclasses"
  end

  def self.project_specific_attributes
    columns.map(&:name).grep(/#{project_attribute_prefix}_/)
  end

  def to_s
    name
  end

  def set_next_poll!
    set_next_poll
    save!
  end

  def set_next_poll
    self.next_poll_at = Time.now + (polling_interval || Project::DEFAULT_POLLING_INTERVAL)
  end

  def needs_poll?
    next_poll_at.nil? || next_poll_at <= Time.now
  end

  def status_url
    latest_status.try(:url)
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

  def as_json(options = {})
    super(:only => :id, :methods => :tag_list)
  end

  def self.build_url_from_fields(params)
    raise NotImplementedError, "Must implement build_url_from_fields in subclasses"
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

  private

  def self.project_attribute_prefix
    name.match(/(.*)Project/)[1].underscore
  end

  def fetch_statuses
    Delayed::Job.enqueue(StatusFetcher::Job.new(self), priority: 1)
  end

end
