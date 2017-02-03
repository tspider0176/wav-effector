require 'rubygems'
require 'wav-file'

SIGNED_SHORT_MAX = "111111111111111".to_i(2)

def bit_per_sample(format)
  format.bitPerSample == 16 ? 's*' : 'c*'
end

def get_wav_array(data_chunk, format)
  data_chunk.data.unpack(bit_per_sample(format)) # datachuck -> dataの配列へunpack
end

def get_peak(wav_array)
  wav_array.max
end

def normalize(wav_array)
  peak = get_peak(wav_array)
  wav_array.map{|data| data * (SIGNED_SHORT_MAX / peak)}
end

file_name = "nc60130.wav"

f = open(file_name)
format = WavFile::readFormat(f)
data_chunk = WavFile::readDataChunk(f)
wavs = get_wav_array(data_chunk, format)
f.close

normalized = get_peak(wavs) == SIGNED_SHORT_MAX ? wavs : normalize(wavs)
data_chunk.data = normalized.pack('s*')

open("#{file_name.split('.').first}-normalized.wav", "w"){|out|
  WavFile::write(out, format, [data_chunk])
}
