require_relative './distortion_effect'

# Implements Overrive distortion
class Overdrive < DistortionEffect
  def initialize(file_name)
    super(file_name)
    @threshold = get_peak / 3
  end

  def run
    peak = get_peak
    overdrive(peak)
  end

  private

  def overdrive(peak)
    @wavs.map do |data|
      case data.abs
      when 0..@threshold then
        2.0 * data
      when (@threshold + 1)..(@threshold * 2) then
        (3.0 - (2.0 - 3.0 * data)**2.0) / 3.0
      when (@threshold * 2 + 1)..peak then
        peak
      end
    end.map(&:to_i)
  end
end
