class ProjectPollingStrategyFactory
  def build_ci_strategy(project)
    case project
      when ConcourseProject
        requester = HttpRequester.new
        ConcourseProjectStrategy.new(requester, ConcourseAuthenticator.new(requester))
      else
        CIPollingStrategy.new(HttpRequester.new)
    end
  end

  def build_tracker_strategy
    TrackerProjectStrategy.new(HttpRequester.new)
  end
end
