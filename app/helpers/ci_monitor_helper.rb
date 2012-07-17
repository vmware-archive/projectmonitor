module CiMonitorHelper
  def static_status_messages_for(project)
    messages = []
    if project.online?
      messages << (project.status.published_at.present? ? "Last built #{project.status.published_at}": "Last build date unknown")
      if project.red?
        messages << (project.status.published_at.present? ? "Red since #{project.red_since} #{build_count_text_for(project)}" : "Red for some time")
      end
    else
      messages << "Could not retrieve status"
    end
    messages
  end

  private

  def build_count_text_for(project)
    return "" unless project.red?
    count = project.red_build_count
    "(#{count} #{count == 1 ? "build" : "builds"})"
  end
end
