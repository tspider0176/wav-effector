require_relative './distortion_effect'

# Implements Fuzz distortion
class Fuzz < DistortionEffect
  def initialize(file_name)
    super(file_name)
  end

  def run
    peak = get_peak
    fuzz(peak, 8, -0.2)
  end

  private

  def fuzz(peak, dist, q)
    @wavs.map do |data|
      if data == (q * peak).to_i
        (((1.0 / dist) + q * peak / 1 - Math.exp(dist * q * peak))).to_i
      else
        (((data - q * peak) / (1 - Math.exp(-1 * dist * (data - q * peak)))) + (q * peak / (1 - Math.exp(dist * q * peak)))).to_i
      end
    end
  end
end
