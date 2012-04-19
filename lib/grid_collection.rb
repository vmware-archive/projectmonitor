require 'delegate'

class GridCollection < SimpleDelegator
  LIMITS = [15, 24, 48]

  def initialize(array, tile_count = nil)
    @upper_limit = tile_count || LIMITS.find { |limit| array.count <= limit }
    validate_size
    @entries = array + Array.new(@upper_limit - array.size)
    super @entries
  end

  private
  def validate_size
    raise ArgumentError, "We never anticipated more than 48 projects. Sorry." unless @upper_limit
  end
end
