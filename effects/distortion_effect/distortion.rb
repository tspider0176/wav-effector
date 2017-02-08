require_relative './distortion_effect'

class Distortion < DistortionEffect
  def initialize(file_name)
    super(file_name)
  end

  def run
    peak = get_peak(@wavs)
    distort(peak)
  end

private
  def get_peak(wav_array)
    wav_array.max
  end

  def sgn(x)
    x > 0 ? 1 : -1
  end

  def distort(peak)
      @wavs.map{|data|
        sgn(data) * (1.0 - Math.exp((-1.0) * data.abs)) * peak.to_f
      }
  end
end
