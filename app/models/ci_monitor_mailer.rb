class CiMonitorMailer < ActionMailer::Base
  default :from => SYSTEM_ADMIN_EMAIL

  def red_over_one_day_notification(projects, options = {})
    @projects = projects
    mail :to => RED_NOTIFICATION_EMAILS,
         :subject => "Projects RED for over one day!"
  end
end
