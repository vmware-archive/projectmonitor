require 'delegate'

class GridCollection < SimpleDelegator
  LIMITS = [15, 24, 48, 63]

  def initialize(array, tile_count = nil)
    @upper_limit = tile_count || LIMITS.find { |limit| array.count <= limit }
    validate_size

    if array.size < @upper_limit
      @entries = array + Array.new(@upper_limit - array.size)
    else
      @entries = array[0...@upper_limit]
    end

    super @entries
  end

  private
  def validate_size
    raise ArgumentError, "We never anticipated more than 63 projects. Sorry." unless @upper_limit
  end
end
