require_relative './distortion_effect'

# Implements distortion effect
class Distortion < DistortionEffect
  def initialize(wav_array)
    super(wav_array)
  end

  def run
    distort(peak)
  end

  private

  def sgn(x)
    x > 0 ? 1 : -1
  end

  def distort(peak)
    @wavs.map do |data|
      sgn(data) * (1.0 - Math.exp(-1.0 * data.abs)) * peak.to_f
    end
  end
end
