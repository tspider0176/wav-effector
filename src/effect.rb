require 'rubygems'
require 'wav-file'

# Effects class [Abstruct]
class Effect
  attr_reader :format
  SIGNED_SHORT_MAX = '111111111111111'.to_i(2)

  def initialize(wav_array)
    @wav_array = wav_array
  end

  def peak
    [@wav_array.max, @wav_array.min.abs].max
  end

  def run
    raise 'Called abstruct method'
  end
end
