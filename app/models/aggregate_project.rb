class AggregateProject < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  has_many :projects

  before_destroy { |record| record.projects.update_all :aggregate_project_id => nil }

  scope :enabled, where(enabled: true)
  scope :with_statuses, joins(:projects => :statuses).uniq
  scope :for_location, lambda { |location| where(:location => location) }

  acts_as_taggable
  validates :name, presence: true

  before_save :clear_empty_location

  def clear_empty_location
    self.location = nil if location.blank?
  end

  def red?
    projects.any?(&:red?)
  end

  def green?
    return false if projects.empty?
    projects.all?(&:green?)
  end

  def online?
    return false if projects.empty?
    projects.all?(&:online?)
  end

  def tracker_project?
    false
  end

  def code
    super.presence || (name ? name.downcase.gsub(" ", '')[0..3] : nil)
  end

  def status
    statuses.last
  end
  alias_method :latest_status, :status

  def statuses
    projects.map(&:latest_status).reject(&:nil?).sort_by(&:id)
  end

  def building?
    projects.any?(&:building?)
  end

  def recent_online_statuses(count = Project::RECENT_STATUS_COUNT)
    ProjectStatus.online(projects, count)
  end

  def status_url
    aggregate_project_path(self)
  end

  def red_since
    breaking_build.try(:published_at)
  end

  def never_been_green?
    projects.all? { |p| p.last_green.blank? }
  end

  def breaking_build
    return statuses.first if never_been_green?
    reds = []
    projects.each do |p|
      reds << p.statuses.find(:last, :conditions => ["online = ? AND success = ? AND published_at IS NOT NULL AND id > ?", true, false, p.last_green.id])
    end
    reds.compact.sort_by(&:published_at).first
  end

  def red_build_count
    return 0 if breaking_build.nil? || !online?
    red_project = projects.detect(&:red?)
    red_project.statuses.count(:conditions => ["online = ? AND id >= ?", true, red_project.breaking_build.id])
  end

  def self.all_with_tags(tags)
    enabled.joins(:projects).find_tagged_with tags, match_all: true
  end

  def as_json(options = {})
    super(:only => :id, :methods => :tag_list)
  end
end
