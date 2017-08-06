require_relative './distortion_effect'

# Implements Overrive distortion
class Overdrive < DistortionEffect
  def initialize(wav_array)
    super(wav_array)
    @threshold = peak / 3
  end

  def run
    overdrive(peak)
  end

  private

  def overdrive(peak)
    @wav_array.map do |data|
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
