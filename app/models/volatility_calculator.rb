require_relative '../../config/initializers/standard_deviation'

class VolatilityCalculator
  def calculate_volatility(last_ten_velocities)
    if last_ten_velocities.any?
      calculated_volatility(last_ten_velocities)
    else
      0
    end
  end

  private

  def calculated_volatility(last_ten_velocities)
    sample_volatility(last_ten_velocities).round(0)
  end

  def sample_volatility(last_ten_velocities)
    mean = last_ten_velocities.mean
    std_dev = last_ten_velocities.standard_deviation
    vol = (std_dev * 100.0) / mean
    vol.nan? ? 0 : vol
  end
end