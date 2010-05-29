module CiMonitorHelper
  def build_count_text_for(project)
    return "" unless project.red?
    count = project.red_build_count
    "(#{count} #{count == 1 ? "build" : "builds"})"
  end

  def relative_status_messages_for(project)
    messages = []
    if project.online?
      messages << ['project_published_at', "Last built #{time_ago_in_words(project.status.published_at)} ago"]
      if project.red?
        messages << ['project_red_since', "Red since #{time_ago_in_words(project.red_since)} ago #{build_count_text_for(project)}"]
      end
    else
      messages << ['project_invalid', "Could not retrieve status"]
    end
    messages
  end

  def static_status_messages_for(project)
    messages = []
    if project.online?
      messages << "Last built #{project.status.published_at}"
      if project.red?
        messages << "Red since #{project.red_since} #{build_count_text_for(project)}"
      end
    else
      messages << "Could not retrieve status"
    end
    messages
  end
end
