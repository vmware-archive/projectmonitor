module CiMonitorHelper
  def build_count_text_for(project)
    return "" unless project.red?
    count = project.red_build_count
    "(#{count} #{count == 1 ? "build" : "builds"})"
  end
end
