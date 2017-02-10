require_relative './distortion_effect'

class Overdrive < DistortionEffect
  def initialize(file_name)
    super(file_name)
    @threshold = get_peak / 3
  end

  def run
    overdrive
  end

private
  def overdrive
    peak = get_peak(@wavs)

    @wavs.map{|data|
      case data.abs
      when 0..@threshold then
        2.0 * data
      when (@threshold + 1)..(@threshold * 2) then
        (3.0 - (2.0 - 3.0 * data) ** 2.0) / 3.0
      when (@threshold * 2 + 1)..(peak) then
        peak
      end
    }.map(&:to_i)
  end
end
