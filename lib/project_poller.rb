class ProjectPoller
  def poll_project(project, polling_strategy, jobs, &project_complete)
    if jobs.empty?
      project_complete.call(false, 'no jobs found')
      return
    end

    batch_job_runner = BatchJobRunner.new
    batch_job_runner.run(jobs, JobRunner.new(project, polling_strategy, project_complete))
  end
end