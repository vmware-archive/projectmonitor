class DashboardGrid
  DEFAULT_LOCATION_GRID_SIZE = 63

  class << self
    def generate(request_params={})
      new(request_params).generate
    end
  end

  def initialize(request_params)
    @request_params = request_params
    @tags = request_params[:tags]
    @locations = request_params[:view]
    @projects = find_projects.sort_by { |p| p.name.to_s.downcase }
  end

  def generate
    if @locations
      generate_with_locations
    else
      generate_without_locations
    end
  end

  private

  def generate_with_locations
    locations = []
    @projects.group_by(&:location).keys.sort{ |l1,l2| group_sort(l1,l2) }.each do |location|
      location_projects = location_groups[location]
      locations << SubGridCollection.new([Location.new(location(location_projects))] + location_projects)
    end
    GridCollection.new(locations.flatten, DEFAULT_LOCATION_GRID_SIZE).each_slice(9).to_a.transpose.flatten
  end

  def generate_without_locations
    GridCollection.new @projects, @request_params[:tiles_count].try(:to_i)
  end

  def find_projects
    if @tags
      generate_with_tags
    else
      generate_projects
    end
  end

  def generate_projects
    Project.standalone + AggregateProject.all
  end

  def generate_with_tags
    aggregate_projects = AggregateProject.all_with_tags(@tags)
    projects_with_aggregates = aggregate_projects.collect(&:projects).flatten.uniq
    Project.find_tagged_with(@tags, match_all: true) - projects_with_aggregates + aggregate_projects
  end

  def group_sort(l1, l2)
    return -1 if ["San Francisco", "SF"].include?(l1)
    return 1 if ["San Francisco", "SF"].include?(l2)
    return 1 if l1.blank?
    return -1 if l2.blank?
    l1 <=> l2
  end


  def location(location_projects)
    location = location_projects.first.try(:location)
    return location if location_projects.all? { |e| e.blank? || e.location == location }
  end

  def location_groups
    @projects.group_by(&:location)
  end

  def sort(projects)
    projects.sort_by(&:name)
  end
end
