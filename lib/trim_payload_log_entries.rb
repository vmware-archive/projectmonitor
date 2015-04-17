class TrimPayloadLogEntries

  LOG_ENTRIES_TO_KEEP = 20

  def run
    Project.all.each do |project|
      if PayloadLogEntry.where(project_id: project.id).count > 0
        payloads = PayloadLogEntry.where(project_id: project.id).order(created_at: :desc).limit(LOG_ENTRIES_TO_KEEP)
        PayloadLogEntry.where("created_at < ? and project_id = ?", payloads.last.created_at, project.id).delete_all
      end
    end
  end
end
