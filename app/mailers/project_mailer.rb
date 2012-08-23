class ProjectMailer < ActionMailer::Base
  default from: "noreply@pivotallabs.com"

  def build_notification(project)
    @project = project
    mail(to: project.notification_email, subject: "#{project.name} is now #{project.color}")
  end

  def error_notification(project, log)
    @project = project
    @log = log
    mail(to: project.notification_email, subject: "Error fetching payload for #{project.name}")
  end
end
