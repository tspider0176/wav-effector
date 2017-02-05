require_relative './effect'

class Normalization < Effect
  SIGNED_SHORT_MAX = "111111111111111".to_i(2)

  def initialize(file_name)
    super(file_name)
    @peak = get_peak(@wavs)
  end

  def run
    @peak == SIGNED_SHORT_MAX ? @wavs : normalize(@wavs)
  end

  def write
    @data_chunk.data = run.pack(bit_per_sample)
    open("#{@file_name.split('.').first}-normalized.wav", "w"){|out|
      WavFile::write(out, @format, [@data_chunk])
    }
  end

private
  def get_peak(wav_array)
    wav_array.max
  end

  def normalize(wav_array)
    wav_array.map{|data| data * (SIGNED_SHORT_MAX.to_f / @peak)}.map(&:to_i)
  end
end
