class CodeClimateApi
  def initialize(project)
    @project = project
    @data = nil
  end

  def current_gpa
    BigDecimal(data["last_snapshot"]["gpa"].to_s) rescue nil
  end

  def previous_gpa
    BigDecimal(data["previous_snapshot"]["gpa"].to_s) rescue nil
  end

  def gpa_change_from_previous
    return nil unless current_gpa && previous_gpa
    current_gpa - previous_gpa
  end

  private

  def data
    @data ||= JSON.parse UrlRetriever.new("https://codeclimate.com/api/repos/#{@project.code_climate_repo_id}.json?api_token=#{@project.code_climate_api_token}").retrieve_content
  end
end
