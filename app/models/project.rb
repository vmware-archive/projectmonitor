class Project < ActiveRecord::Base
  has_many :statuses, :class_name => "ProjectStatus", :order => "id DESC"
  
  acts_as_taggable

  validates_presence_of :name
  validates_presence_of :cc_rss_url
  validates_format_of :cc_rss_url, :with => /http:\/\/.*.rss$/

  def status
    statuses.first || ProjectStatus.new
  end

  def online?
    status.online?
  end

  def green?
    status.online? && status.success?
  end

  def red?
    status.online? && !status.success?
  end

  def red_since
    breaking_build.nil? ? nil : breaking_build.published_at
  end

  def red_build_count
    return 0 if breaking_build.nil? || !online?
    statuses.count(:conditions => ["online = ? AND id >= ?", true, breaking_build.id])
  end

  def build_status_url
    return nil if cc_rss_url.nil?

    url_components = URI.parse(cc_rss_url)
    returning("#{url_components.scheme}://#{url_components.host}") do |url|
      url << ":#{url_components.port}" if url_components.port
      url << "/XmlStatusReport.aspx"
    end
  end

  def cc_project_name
    return nil if cc_rss_url.nil?
    URI.parse(cc_rss_url).path.scan(/^.*\/(.*)\.rss/i)[0][0]
  end

  def to_s
    name
  end
  
  def recent_online_statuses(count = 10)
    statuses.reject{|s| !s.online}.reverse.last(count)
  end

  private

  def last_green
    @last_green ||= statuses.detect(&:success?)
  end

  def breaking_build
    @breaking_build ||= if last_green.nil?
      statuses.last
    else
      statuses.find(:last, :conditions => ["online = ? AND success = ? AND id > ?", true, false, last_green.id])
    end
  end
end
