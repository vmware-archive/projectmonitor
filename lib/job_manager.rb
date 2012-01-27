module JobManager
  def self.jobs_exist?(queue_name)
     Delayed::Job.where("queue = ?", queue_name).present?
  end

end