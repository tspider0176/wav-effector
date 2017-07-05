require_relative './effect'

# Implements normalization effect
class Normalization < Effect
  def initialize(wav_array)
    super(wav_array)
  end

  def run
    peak == SIGNED_SHORT_MAX ? @wav_array : normalize
  end

  private

  def normalize
    @wav_array.map do |data|
      data * (SIGNED_SHORT_MAX.to_f / peak)
    end.map(&:to_i)
  end
end
