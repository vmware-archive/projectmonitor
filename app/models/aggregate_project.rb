class AggregateProject < ActiveRecord::Base
  include ActionController::UrlWriter
  has_many :projects

  scope :with_projects, joins(:projects).where(:enabled => true).group('aggregate_projects.id')

  def red?
    projects.detect {|p| p.red? }
  end

  def green?
    return false if projects.empty?
    
    projects.all? {|p| p.green? }
  end

  def online?
    return false if projects.empty?
    projects.all? {|p| p.online? }
  end

  def status
    projects.collect {|p| p.status }.sort_by(&:id).last
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

end
