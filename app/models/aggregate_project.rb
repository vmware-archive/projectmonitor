class AggregateProject < ActiveRecord::Base
  has_many :projects

  before_destroy { |record| record.projects.update_all aggregate_project_id: nil }

  scope :enabled, -> { where(enabled: true) }
  scope :with_statuses, -> { joins(projects: :statuses).uniq }
  scope :displayable, lambda { |tags=nil|
    scope = enabled.joins(:projects).select("DISTINCT aggregate_projects.*").order('code ASC')
    return scope.tagged_with(tags, any: true) if tags
    scope
  }

  acts_as_taggable
  validates :name, presence: true

  def state
    states = projects.map(&:state).uniq
    if failing_state = states.detect(&:failure?)
      failing_state
    elsif states.length == 1
      states.first
    elsif !online?
      Project::State.offline
    else
      # TODO: Does this have to be indeterminate?
      Project::State.indeterminate
    end
  end

  delegate :failure?, :success?, :indeterminate?, :offline?, :to_s, to: :state

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
    statuses.last || ProjectStatus.new
  end
  alias_method :latest_status, :status

  def statuses
    projects.map(&:latest_status).compact.sort_by(&:build_id)
  end

  def building?
    projects.any?(&:building?)
  end

  def recent_statuses
    ProjectStatus.where(project_id: project_ids).recent.limit(Project::RECENT_STATUS_COUNT)
  end

  def red_since
    breaking_build.try(:published_at)
  end

  def never_been_green?
    projects.all? { |p| p.last_green.blank? }
  end

  def build
    projects.first
  end

  def breaking_build
    return statuses.first if never_been_green?
    red_statuses = projects.collect do |p|
      last_green = p.last_green
      if last_green
        p.breaking_build
      else
        p.statuses.last
      end
    end
    red_statuses.compact.reject{|status| status.published_at.nil? }.sort_by(&:published_at).first
  end

  def red_build_count
    return 0 if breaking_build.nil? || !online?
    red_project = projects.detect(&:failure?)
    red_project.statuses.where("id >= ?", red_project.breaking_build.id).count
  end

  def status_in_words
    state.to_s
  end
end
