require_relative './effect'

# Implements normalization effect
class Normalization < Effect
  def initialize(file_name)
    super(file_name)
    @peak = get_peak
  end

  def run
    @peak == SIGNED_SHORT_MAX ? @wavs : normalize(@wavs)
  end

  def write
    @data_chunk.data = run.pack(bit_per_sample)
    open("#{@file_name.split('.').first}-normalized.wav", 'w') do |out|
      WavFile.write(out, @format, [@data_chunk])
    end
  end

  private

  def get_peak(wav_array)
    wav_array.max
  end

  def normalize(wav_array)
    wav_array.map do |data|
      data * (SIGNED_SHORT_MAX.to_f / @peak)
    end.map(&:to_i)
  end
end
