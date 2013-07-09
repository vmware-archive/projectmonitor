class AggregateProject < ActiveRecord::Base
  has_many :projects

  before_destroy { |record| record.projects.update_all :aggregate_project_id => nil }

  scope :enabled, -> { where(enabled: true) }
  scope :with_statuses, -> { joins(:projects => :statuses).uniq }
  scope :displayable, lambda { |tags=nil|
    scope = enabled.joins(:projects).select("DISTINCT aggregate_projects.*").order('code ASC')
    return scope.tagged_with(tags, :any => true) if tags
    scope
  }

  scope :tagged, lambda { |tags|
    return tagged_with(tags, :any => true) if tags
    all
  }

  acts_as_taggable rescue nil
  validates :name, presence: true

  def red?
    projects.any?(&:red?)
  end

  def yellow?
    projects.present? && projects.all?(&:yellow?)
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
    statuses.last || ProjectStatus.new
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
    red_project = projects.detect(&:red?)
    red_project.statuses.where("id >= ?", red_project.breaking_build.id).count
  end

  def as_json(options = {})
    options.merge!(root: false, except: [:status])
    super(options).merge!("aggregate" => true, "status" => status_in_words)
  end

  def status_in_words
    if red?
      'failure'
    elsif green?
      'success'
    elsif yellow?
      'indeterminate'
    else
      'offline'
    end
  end
end
