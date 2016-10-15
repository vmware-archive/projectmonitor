class ProjectPollingStrategyFactory
  def build_ci_strategy(project)
    case project
      when ConcourseProject
        requester = AsynchronousHttpRequester.new
        ConcourseProjectStrategy.new(requester, ConcourseAuthenticator.new(requester))
      else
        CIPollingStrategy.new(AsynchronousHttpRequester.new)
    end
  end

  def build_tracker_strategy
    TrackerProjectStrategy.new(AsynchronousHttpRequester.new)
  end
end
