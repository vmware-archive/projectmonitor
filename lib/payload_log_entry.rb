class PayloadLogEntry < ActiveRecord::Base
  belongs_to :project

  default_scope order: "created_at DESC"
  scope :reverse_chronological, order: "created_at DESC"

  after_save :send_notifications

  def self.latest
    reverse_chronological.limit(1).first
  end

  def to_s
    "#{method} #{status}"
  end

  def send_notifications
    return unless project && project.try(:notification_email).present?
    ProjectMailer.build_notification(project).deliver if project.send_build_notifications && status == "successful"
    ProjectMailer.error_notification(project, self).deliver if project.send_error_notifications && status == "failed"
  end
end
