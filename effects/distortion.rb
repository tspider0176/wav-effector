require_relative './effect'
require_relative './normalization'

class Distortion < Effect
  def initialize(file_name)
    super(file_name)
  end

  def run
    distort(@wavs)
  end

  def write
    @data_chunk.data = run.pack(bit_per_sample)
    open("#{@file_name.split('.').first}-distorted.wav", "w"){|out|
      WavFile::write(out, @format, [@data_chunk])
    }
  end

private
  def sgn(x)
    x > 0 ? 1 : -1
  end

  def distort(wav_array)
    wav_array.map{|data| data * (1.0 - Math.exp((-1.0) * data.abs))}
  end
end
