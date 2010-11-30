class CiMonitorMailer < ActionMailer::Base

  def red_over_one_day_notification(projects, options = {})
    @projects = projects
    from("Pivotal CiMonitor <pivotal-cimonitor@example.com>")
    recipients(RED_NOTIFICATION_EMAILS)
    subject("Projects RED for over one day!")
    multipart("red_over_one_day_notification", :projects => projects)
  end
end
