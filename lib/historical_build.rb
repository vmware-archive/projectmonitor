class HistoricalBuild
  def initialize(build_history, status, index)
    self.build_history = build_history
    self.status = status
    self.index = index
  end

  def box_opacity
    1.0 - (box_opacity_step * index)
  end

  def indicator_opacity
    ((1.0 - (indicator_opacity_step * index)) / box_opacity).round(3)
  end

  def result
    status.in_words
  end

  def url
    status.url
  end

  private

  def box_opacity_step
    build_history.box_opacity_step
  end

  def indicator_opacity_step
    build_history.indicator_opacity_step
  end

  attr_accessor :build_history, :status, :index
end
