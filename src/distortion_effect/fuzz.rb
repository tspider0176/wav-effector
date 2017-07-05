require_relative './distortion_effect'

# Implements Fuzz distortion
class Fuzz < DistortionEffect
  def initialize(wav_array)
    super(wav_array)
  end

  def run
    fuzz(peak, 8, -0.2)
  end

  private

  def fuzz_exp(peak, dist, q, data)
    if data == (q * peak).to_i
      (((1.0 / dist) + q * peak / 1 - Math.exp(dist * q * peak))).to_i
    else
      (((data - q * peak) / (1 - Math.exp(-1 * dist * (data - q * peak)))) + (q * peak / (1 - Math.exp(dist * q * peak)))).to_i
    end
  end

  def fuzz(peak, dist, q)
    @wavs.map do |data|
      fuzz_exp(peak, dist, q, data)
    end
  end
end
