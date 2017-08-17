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
    @wav_array.map do |data|
      x = data.fdiv(peak)
      y = sgn(x) * (1.0 - Math.exp(-5.0 * x.abs))
      (y * SIGNED_SHORT_MAX).to_i
    end
  end
end
