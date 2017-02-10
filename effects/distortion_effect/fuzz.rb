require_relative './distortion_effect'

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
      @wavs.map{|data|
        data == (q * peak.to_f).to_i ? ((1/dist) + q / 1 - Math.exp(dist * q)) * peak.to_f : (((data - q) / (1 - Math.exp((-1) * dist * (data - q))) + (q / (1 - Math.exp(dist * q)))))
      }
  end
end
