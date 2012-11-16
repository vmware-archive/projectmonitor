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

  private

  def data
    @data ||= JSON.parse UrlRetriever.retrieve_content_at("https://codeclimate.com/api/repos/#{@project.code_climate_repo_id}.json?api_token=#{@project.code_climate_api_token}")
  end
end
