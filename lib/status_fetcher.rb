module StatusFetcher
  class Job < Struct.new(:project)
    def perform
      retrieve_status
      retrieve_building_status
      retrieve_velocity

      project.set_next_poll!
    end

    private

    def retrieve_status
      StatusFetcher.retrieve_status_for(project)
    end

    def retrieve_building_status
      StatusFetcher.retrieve_building_status_for(project)
    end

    def retrieve_velocity
      StatusFetcher.retrieve_velocity_for(project)
    end
  end

  class << self
    def fetch_all
      projects = Project.all.select(&:needs_poll?)
      projects.each do |project|
        Delayed::Job.enqueue StatusFetcher::Job.new(project)
      end
    end

    def retrieve_status_for(project)
      project.fetch_new_statuses
    rescue Net::HTTPError => e
      error = "HTTP Error retrieving status for project '##{project.id}': #{e.message}"
      project.statuses.create(:error => error) unless project.status.error == error
    end

    def retrieve_building_status_for(project)
      status = project.fetch_building_status
      project.update_attribute(:building, status.building?)
    rescue Net::HTTPError => e
      project.update_attribute(:building, false)
    end

    def retrieve_velocity_for(project)
      return unless project.tracker_project?

      project.current_velocity = TrackerApi.new(project.tracker_auth_token).current_velocity(project.tracker_project_id)
    end
  end
end

