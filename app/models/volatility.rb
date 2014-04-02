class Volatility < Array

  def self.calculate(velocities)
    Volatility.new(velocities).value
  end

  def value
    vol = (standard_deviation * 100.0) / mean
    vol.nan? ? 0 : vol.round(0)
  end
end
