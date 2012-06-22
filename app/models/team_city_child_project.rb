class TeamCityChildProject
  include TeamCityBuildStatusParsing
  include TeamCityProjectWithChildren
  attr_accessor :feed_url, :auth_username, :auth_password, :build_id

  def initialize(opts)
    opts.each do |attr,value|
      self.public_send("#{attr}=", value)
    end
  end

  def building?
    live_building_status.building? || children.any?(&:building?)
  end

  def red?
    live_status_hash[:status] != 'SUCCESS' || children.any?(&:red?)
  end

  def last_build_time
    [live_status_hash[:published_at], *children.map(&:last_build_time)].max
  end

  private

  def live_status_hash
    @live_status_hash ||= live_status_hashes.first
  end
end
