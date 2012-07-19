require File.expand_path("../historical_build", __FILE__)

class BuildHistory
  def initialize(statuses)
    self.statuses = statuses
  end

  def each_build(&block)
    statuses.each_with_index do |status, index|
      yield HistoricalBuild.new(self, status, index)
    end
  end

  def box_opacity_step
    0.05
  end

  def indicator_opacity_step
    0.1
  end

  private

  attr_accessor :statuses
end
