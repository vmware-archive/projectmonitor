class Project < ActiveRecord::Base
  RECENT_STATUS_COUNT = 10
  DEFAULT_POLLING_INTERVAL = 120
  has_many :statuses, :class_name => "ProjectStatus", :order => "id DESC", :limit => RECENT_STATUS_COUNT
  belongs_to :aggregate_project

  scope :standalone, where(:enabled => true, :aggregate_project_id => nil).order(:name)

  acts_as_taggable

  validates_presence_of :name
  validates_presence_of :feed_url

  def status
    statuses.first || ProjectStatus.new
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
    self.next_poll_at = Time.now + (self.polling_interval || Project::DEFAULT_POLLING_INTERVAL)
    self.save!
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
end
