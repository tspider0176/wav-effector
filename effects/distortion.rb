require_relative './effect'
require_relative './normalization'

class Distortion < Effect
  def initialize(file_name, algorithm)
    super(file_name)
    @algorithm = algorithm
  end

  def run
    peak = get_peak(@wavs)
    distort(@wavs, @algorithm, peak)
  end

  def write
    @data_chunk.data = run.pack(bit_per_sample)
    open("#{@file_name.split('.').first}-distorted.wav", "w"){|out|
      WavFile::write(out, @format, [@data_chunk])
    }
  end

private
  def get_peak(wav_array)
    wav_array.max
  end

  def sgn(x)
    x > 0 ? 1 : -1
  end

  def distort(wav_array, algorithm, peak)
    wav_array.map{|data|
      sgn(data) * (1.0 - Math.exp((-1.0) * data.abs)) * peak.to_f
    } if algorithm == 'fuzz'
  end
end
