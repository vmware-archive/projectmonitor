class PayloadLogEntry < ActiveRecord::Base
  belongs_to :project
  after_create :purge_old_logs

  LOG_ENTRIES_TO_KEEP = 20

  default_scope { order('created_at DESC') }
  scope :reverse_chronological, -> () { order('created_at DESC') }

  def self.latest
    reverse_chronological.limit(1).first
  end

  def to_s
    "#{update_method} #{status}"
  end

  def purge_old_logs
     payloads = PayloadLogEntry.where(project_id: project_id).order(created_at: :desc).limit(LOG_ENTRIES_TO_KEEP)
     PayloadLogEntry.where("created_at < ? and project_id = ?", payloads.last.created_at, project_id).delete_all
  end
end
