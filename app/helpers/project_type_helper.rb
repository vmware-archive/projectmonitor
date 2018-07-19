module ProjectTypeHelper
  def self.find_type(type)
    if type == 'JenkinsProject'
      JenkinsProject
    elsif type == 'CruiseControlProject'
      CruiseControlProject
    elsif type == 'SemaphoreProject'
      SemaphoreProject
    elsif type == 'TeamCityProject'
      TeamCityProject
    elsif type == 'TeamCityRestProject'
      TeamCityRestProject
    elsif type == 'TravisProject'
      TravisProject
    elsif type == 'TravisProProject'
      TravisProProject
    elsif type == 'TddiumProject'
      TddiumProject
    elsif type == 'CircleCiProject'
      CircleCiProject
    elsif type == 'ConcourseV1Project'
      ConcourseV1Project
    elsif type == 'ConcourseProject'
      ConcourseProject
    elsif type == 'CodeshipProject'
      CodeshipProject
    else
      raise 'Invalid Project Type'
    end
  end
end
