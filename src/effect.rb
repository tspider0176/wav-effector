require 'rubygems'
require 'wav-file'

# Effects
class Effect
  attr_reader :format
  SIGNED_SHORT_MAX = '111111111111111'.to_i(2)

  def initialize(file_name)
    f = open(file_name)
    @file_name = file_name
    @format = WavFile.readFormat(f)
    @data_chunk = WavFile.readDataChunk(f)
    @wavs = get_wav_array
    f.close
  end

  def wav_array
    @data_chunk.data.unpack(bit_per_sample)
  end

  def bit_per_sample
    @format.bitPerSample == 16 ? 's*' : 'c*'
  end

  def peak
    [@wavs.max, @wavs.min.abs].max
  end

  def write
    @data_chunk.data = run.pack(bit_per_sample)
    open("#{@file_name.split('.').first}-plain.wav", 'w') do |out|
      WavFile.write(out, @format, [data_chunk])
    end
  end

  def run
    @wavs
  end
end
