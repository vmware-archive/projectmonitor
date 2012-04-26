class Project < ActiveRecord::Base
  RECENT_STATUS_COUNT = 10
  DEFAULT_POLLING_INTERVAL = 120

  has_many :statuses, :class_name => "ProjectStatus", :order => "id DESC", :limit => RECENT_STATUS_COUNT, :dependent => :destroy
  belongs_to :latest_status, :class_name => "ProjectStatus"
  belongs_to :aggregate_project

  scope :enabled, where(:enabled => true)
  scope :standalone, enabled.where(:aggregate_project_id => nil)
  scope :with_statuses, joins(:statuses).uniq
  scope :for_location, lambda { |location| where(location: location) }
  scope :unknown_location, where("location IS NULL OR location = ''")

  acts_as_taggable

  validates :name, presence: true
  validates :feed_url, presence: true
  validates_length_of :location, :maximum => 20, :allow_blank => true

  def before_save
    if changed.include?('polling_interval')
      set_next_poll
    end
  end

  def code
    self[:code].presence || (name ? name.downcase.gsub(" ", '')[0..3] : nil)
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
    breaking_build.nil? ? nil : breaking_build.published_at
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
    feed_url.blank? ? nil : feed_url
  end

  def to_s
    name
  end

  def recent_online_statuses(count = RECENT_STATUS_COUNT)
    ProjectStatus.online(self, count)
  end

  def set_next_poll!
    set_next_poll
    self.save!
  end

  def set_next_poll
    self.next_poll_at = Time.now + (self.polling_interval || Project::DEFAULT_POLLING_INTERVAL)
  end

  def needs_poll?
    self.next_poll_at.nil? || self.next_poll_at <= Time.now
  end

  def parse_project_status(content)
    ProjectStatus.new(:online => false, :success => false)
  end

  def parse_building_status(content)
    BuildingStatus.new(false)
  end

  def url
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

  def tracker_volatility_healthy?
    tracker_volatility <= 30
  end

  def tracker_unaccepted_stories_healthy?
    tracker_num_unaccepted_stories < 6
  end
end
