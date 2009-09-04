module ApplicationHelper
  def logo
    internal? ? 'pulse-logo.png' : 'ci-logo.png'
  end

  def title
    internal? ? "Pivotal Pulse" : "Pivotal Labs CI"
  end

  def historical_status_list(project)
    project.recent_online_statuses(9).map{|status|
      "<span class='item #{status.in_words} #{'no-background'}'>#{historical_status_image(status)}</span>"
    }.join
  end

  def historical_status_image(status)
    age_in_hours = ((Time.now - status.published_at)/60/60).to_i
    icon_number = icon_number_for_age_in_hours(age_in_hours)
    result = "<a href='#{status.url}'>"
    case status.in_words
      when 'success'
        result += "<img src='/images/green#{icon_number}.png' border='0' />"
      when 'failure'
        result += "<img src='/images/red#{icon_number}.png' border='0' />"
    end
    result + "</a>"
  end

  private

  def internal?
    RAILS_ENV == 'internal'
  end

  def icon_number_for_age_in_hours(age_in_hours)
    return 1 if age_in_hours < 4
    return 2 if age_in_hours < 12
    return 3 if age_in_hours < 48
    return 4 if age_in_hours < 168
    return 5
  end

end
