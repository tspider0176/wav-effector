require 'rubygems'
require 'wav-file'

class Effect
  def initialize(file_name)
    f = open(file_name)
    @file_name = file_name
    @format = WavFile::readFormat(f)
    @data_chunk = WavFile::readDataChunk(f)
    @wavs = get_wav_array
    f.close
  end

  def get_wav_array
    @data_chunk.data.unpack(bit_per_sample)
  end

  def bit_per_sample
    @format.bitPerSample == 16 ? 's*' : 'c*'
  end

  def write
    @data_chunk.data = run.pack(bit_per_sample)
    open("#{@file_name.split('.').first}-plain.wav", "w"){|out|
      WavFile::write(out, @format, [data_chunk])
    }
  end

  def run
    @wavs
  end
end
