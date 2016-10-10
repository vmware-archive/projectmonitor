class ProjectPollingStrategyFactory
  def build_ci_strategy(project)
    case project
      when ConcourseProject
        ConcourseProjectStrategy.new
      else
        CIPollingStrategy.new(HttpRequester.new)
    end
  end

  def build_tracker_strategy
    TrackerProjectStrategy.new(HttpRequester.new)
  end
end
