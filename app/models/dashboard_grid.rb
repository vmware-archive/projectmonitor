module DashboardGrid
  LOCATION_GRID_SIZE = 63
  LOCATION_SLICE = 63 / 7
  DEFAULT_GRID_SIZE = 15

  class << self

    def arrange(projects, options = {})
      projects = projects.map {|p| ProjectDecorator.decorate p}

      group_by_location = options[:view]
      if group_by_location
        grid_size = LOCATION_GRID_SIZE
        arrange_with_locations projects, grid_size
      else
        grid_size = (options[:tiles_count] || DEFAULT_GRID_SIZE).to_i
        arrange_without_locations projects, grid_size
      end
    end

    private

    def arrange_with_locations projects, grid_size
      grouped_projects = group_by_location projects

      location_grids = locations(grouped_projects).map do |location|
        location_projects = sort_projects grouped_projects[location]
        SubGridCollection.new([Location.new(location)] + location_projects)
      end

      GridCollection.new(location_grids.flatten, grid_size).each_slice(LOCATION_SLICE).to_a.transpose.flatten
    end

    def arrange_without_locations projects, grid_size
      GridCollection.new sort_projects(projects), grid_size
    end

    def sort_projects projects
      projects.sort_by { |p| p.code.try(:downcase) }
    end

    def group_by_location projects
      projects.group_by do |project|
        project.location
      end
    end

    def locations grouped_projects
      grouped_projects.keys.sort do |left, right|
        location_sort(left, right)
      end
    end

    def location_sort(l1, l2)
      return -1 if l1 == 'SF'
      return 1 if l2 == 'SF'
      return 1 if l1.blank?
      return -1 if l2.blank?
      l1 <=> l2
    end

  end

end
