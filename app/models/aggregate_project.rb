class AggregateProject < ActiveRecord::Base
  include ActionController::UrlWriter
  has_many :projects

  scope :with_projects, joins(:projects).where(:aggregate_projects => {:enabled => true}).select("distinct aggregate_projects.*")

  acts_as_taggable

  def red?
    projects.detect {|p| p.red? }
  end

  def green?
    return false if projects.empty?
    
    projects.all? {|p| p.green? }
  end

  def online?
    return false if projects.empty?
    projects.all?(&:online?)
  end

  def status
    statuses.last
  end

  def statuses
    projects.collect {|p| p.status }.sort_by(&:id)
  end

  def building?
    projects.detect{|p| p.building? }
  end

  def recent_online_statuses(count = Project::RECENT_STATUS_COUNT)
    ProjectStatus.online(projects, count)
  end

  def url
    aggregate_project_path(self)
  end

  def red_since
    breaking_build.nil? ? nil : breaking_build.published_at
  end

  def never_been_green?
    green = false
    projects.each do |p|
      green = true if p.last_green.present?
    end
    !green
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

end
