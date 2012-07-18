class Project < ActiveRecord::Base
  RECENT_STATUS_COUNT = 10
  DEFAULT_POLLING_INTERVAL = 30

  has_many :statuses, :class_name => "ProjectStatus", :order => "id DESC", :limit => RECENT_STATUS_COUNT, :dependent => :destroy
  belongs_to :aggregate_project

  serialize :last_ten_velocities, Array
  serialize :serialized_feed_url_parts, Hash

  scope :enabled, where(:enabled => true)
  scope :standalone, enabled.where(:aggregate_project_id => nil)
  scope :with_statuses, joins(:statuses).uniq
  scope :for_location, lambda { |location| where(location: location) }
  scope :unknown_location, where("location IS NULL OR location = ''")

  acts_as_taggable

  validates :name, presence: true
  validates :feed_url, presence: true
  validates :type, presence: true
  validates_length_of :location, :maximum => 20, :allow_blank => true

  before_save :check_next_poll

  attr_accessible :aggregate_project_id,
    :feed_url, :code, :location, :name, :enabled, :polling_interval, :type, :tag_list,
    :auth_password, :auth_username,
    :tracker_auth_token, :tracker_project_id,
    :ec2_monday, :ec2_tuesday, :ec2_wednesday, :ec2_thursday, :ec2_friday, :ec2_saturday, :ec2_sunday,
    :ec2_elastic_ip, :ec2_instance_id, :ec2_secret_access_key, :ec2_access_key_id, :ec2_start_time, :ec2_end_time, :serialized_feed_url_parts

  def check_next_poll
    set_next_poll if changed.include?('polling_interval')
  end

  def code
    super.presence || name.downcase.gsub(" ", '')[0..3]
  end

  def latest_status
    ProjectStatus.where(project_id: id).reverse_chronological.limit(1).first
  end

  def status
    latest_status || ProjectStatus.new
  end

  def online?
    status.online?
  end

  def green?
    status.online? && status.success?
  end

  def red?
    status.online? && !status.success?
  end

  def red_since
    breaking_build.try(:published_at)
  end

  def red_build_count
    return 0 if breaking_build.nil? || !online?
    statuses.count(:conditions => ["online = ? AND id >= ?", true, breaking_build.id])
  end

  def build_status_url
    return nil if feed_url.nil?

    url_components = URI.parse(feed_url)
    ["#{url_components.scheme}://#{url_components.host}"].tap do |url|
      url << ":#{url_components.port}" if url_components.port
      url << "/XmlStatusReport.aspx"
    end.join
  end

  def project_name
    feed_url.presence
  end

  def to_s
    name
  end

  def recent_online_statuses(count = RECENT_STATUS_COUNT)
    ProjectStatus.online(self, count)
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
    status.url
  end

  def last_green
    @last_green ||= statuses.where(:success => true).first
  end

  def breaking_build
    @breaking_build ||= if last_green.nil?
      statuses.where(:online => true, :success => false).last
    else
      statuses.find(:last, :conditions => ["online = ? AND success = ? AND id > ?", true, false, last_green.id])
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

  def self.feed_url_fields
    raise NotImplementedError, "Must implement feed_url_fields in subclasses"
  end

  def self.build_url_from_fields(params)
    raise NotImplementedError, "Must implement build_url_from_fields in subclasses"
  end

  def processor
    raise NotImplementedError, "Must implement processor in subclasses"
  end

  def to_partial_path
    "dashboards/project"
  end
end
