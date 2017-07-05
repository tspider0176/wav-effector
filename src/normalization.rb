require_relative './effect'

# Implements normalization effect
class Normalization < Effect
  def initialize(wav_array)
    super(wav_array)
  end

  def run
    if peak == SIGNED_SHORT_MAX
      @wav_array
    else
      normalize(SIGNED_SHORT_MAX.to_f / peak)
    end
  end

  private

  def normalize(rate)
    @wav_array.map do |data|
      data * rate
    end.map(&:to_i)
  end
end
