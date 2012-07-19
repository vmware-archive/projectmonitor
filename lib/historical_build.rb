class HistoricalBuild
  def initialize(build_history, status, index)
    self.build_history = build_history
    self.status = status
    self.index = index
  end

  delegate :url, to: :status

  def box_opacity
    1.0 - (box_opacity_step * index)
  end

  def indicator_opacity
    (1.0 - (indicator_opacity_step * index)) / box_opacity
  end

  def result
    status.in_words
  end

  private

  delegate :box_opacity_step, :indicator_opacity_step, to: :build_history
  attr_accessor :build_history, :status, :index
end
