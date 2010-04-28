class CiMonitorNotifier
  def self.send_red_over_one_day_notifications
    projects = Project.find(:all, :conditions => {:enabled => true}).select do |project|
      project.red_since && project.red_since < Clock.now - 1.day
    end
    CiMonitorMailer.deliver_red_over_one_day_notification(projects) unless projects.empty?
  end
end
