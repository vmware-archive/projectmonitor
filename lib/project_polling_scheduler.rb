#
# Asynchronous IO (via the Reactor model) can be a little confusing, so a bit
# of an explanation is in order:
#
# This poller basically looks for all projects that need updating, then asks
# the project to build a workload, which is a list of jobs that need to be
# completed. A job is essentially a URL that needs to be fetched.
#
# When the complete list of jobs has been completed, the handler is notified and
# the project is updated. The workload model is used as jobs can be completed
# in any order.
#
class ProjectPollingScheduler
  def initialize(helper=ProjectPollerHelper.new)
    @poll_period = 60
    @tracker_poll_period = 300
    @helper = helper
  end

  def run
    EM.run do
      EM.add_periodic_timer(@poll_period) do
        @helper.poll_projects
      end

      EM.add_periodic_timer(@tracker_poll_period) do
        @helper.poll_tracker
      end
    end
  end

  def run_once
    if @helper.updateable_projects.count > 0
      EM.run do
        @helper.poll_projects do
          EM.stop_event_loop
        end
      end
    end

    if @helper.projects_with_tracker.count > 0
      EM.run do
        @helper.poll_tracker do
          EM.stop_event_loop
        end
      end
    end
  end

  def stop
    EM.stop_event_loop
  end
end