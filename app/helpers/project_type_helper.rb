module ProjectTypeHelper
  def self.find_type(type)
    raise 'Invalid Project Type' unless valid_project_type?(type)

    type.constantize
  end

  private

  def self.valid_project_type?(type)
    %w[
      JenkinsProject
      CruiseControlProject
      SemaphoreProject
      TeamCityProject
      TeamCityRestProject
      TravisProject
      TravisProProject
      TddiumProject
      CircleCiProject
      ConcourseV1Project
      ConcourseProject
      CodeshipProject
   ].include?(type)
  end
end
