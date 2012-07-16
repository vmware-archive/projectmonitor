class BuildingStatus
  def initialize(building)
    @building = building
  end

  attr_accessor :building, :error
  def building?
    !!@building
  end
end
