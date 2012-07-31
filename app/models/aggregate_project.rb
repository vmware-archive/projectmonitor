class AggregateProject < ActiveRecord::Base
  has_many :projects

  before_destroy { |record| record.projects.update_all :aggregate_project_id => nil }

  scope :enabled, where(enabled: true)
  scope :with_statuses, joins(:projects => :statuses).uniq
  scope :for_location, lambda { |location| where(:location => location) }
  scope :displayable, lambda { |tags|
    scope = enabled
    return scope.all_with_tags(tags) if tags
    scope
  }

  acts_as_taggable
  validates :name, presence: true

  def self.all_with_tags(tags)
    enabled.joins(:projects).find_tagged_with tags, match_all: true
  end

  def red?
    projects.any?(&:red?)
  end

  def green?
    projects.present? && projects.all?(&:green?)
  end

  def online?
    projects.present? && projects.all?(&:online?)
  end

  def tracker_project?
    false
  end

  def code
    super.presence || name.downcase.gsub(" ", '')[0..3]
  end

  def status
    statuses.last
  end
  alias_method :latest_status, :status

  def statuses
    projects.map(&:latest_status).reject(&:nil?).sort_by(&:build_id)
  end

  def building?
    projects.any?(&:building?)
  end

  def recent_statuses(count = Project::RECENT_STATUS_COUNT)
    ProjectStatus.recent(projects, count)
  end

  def red_since
    breaking_build.try(:published_at)
  end

  def never_been_green?
    projects.all? { |p| p.last_green.blank? }
  end

  def breaking_build
    return statuses.first if never_been_green?
    red_statuses = projects.collect do |p|
      last_green = p.last_green
      if last_green
        p.breaking_build
      else
        p.statuses.first
      end
    end
    red_statuses.compact.reject{|status| status.published_at.nil? }.sort_by(&:published_at).first
  end

  def red_build_count
    return 0 if breaking_build.nil? || !online?
    red_project = projects.detect(&:red?)
    red_project.statuses.count(:conditions => ["id >= ?", red_project.breaking_build.id])
  end

  def as_json(options = {})
    super(:only => :id, :methods => :tag_list)
  end

  def to_partial_path
    "dashboards/aggregate_project"
  end
end
