require 'delegate'

class SubGridCollection < GridCollection
  DEFAULT_TILE_COUNT = 9

  def initialize(array, tile_count = nil)
    tile_count ||= DEFAULT_TILE_COUNT
    super(array, tile_count)
  end

  protected

  def upper_limit(array, tile_count)
    return tile_count if array.empty?
    return array.count if array.count % tile_count == 0
    array.count + (tile_count - (array.count % tile_count))
  end

end
