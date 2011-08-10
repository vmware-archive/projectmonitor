class Project < ActiveRecord::Base
  RECENT_STATUS_COUNT = 10
  DEFAULT_POLLING_INTERVAL = 120

  has_many :statuses, :class_name => "ProjectStatus", :order => "id DESC", :limit => RECENT_STATUS_COUNT
  belongs_to :latest_status, :class_name => "ProjectStatus"
  belongs_to :aggregate_project

  scope :standalone, where(:enabled => true, :aggregate_project_id => nil)

  acts_as_taggable

  validates_presence_of :name
  validates_presence_of :feed_url
  validate :ec2_presence

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

  def has_auth?
    auth_username.present? || auth_password.present?
  end

  private
  def ec2_presence
    unless self.ec2_instance_id.blank? && self.ec2_access_key_id.blank? && self.ec2_secret_access_key.blank? && has_no_day?
      errors.add(:ec2_instance_id, "must be present if using Lobot") if self.ec2_instance_id.blank?
      errors.add(:ec2_access_key_id, "must be present if using Lobot") if self.ec2_access_key_id.blank?
      errors.add(:ec2_secret_access_key, "must be present if using Lobot") if self.ec2_secret_access_key.blank?
      errors.add_to_base("Must have a day checked if using Lobot") if has_no_day?
    end
  end

  def has_no_day?
    [:ec2_monday, :ec2_tuesday, :ec2_wednesday, :ec2_thursday, :ec2_friday, :ec2_saturday, :ec2_sunday].all? do |day|
      self.send(day) != true
    end
  end
end
