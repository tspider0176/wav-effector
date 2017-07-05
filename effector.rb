require 'rubygems'
require 'wav-file'

require_relative 'src/effect'
require_relative 'src/normalization'
require_relative 'src/distortion_effect/distortion'
require_relative 'src/distortion_effect/overdrive'
require_relative 'src/distortion_effect/fuzz'

# Treat effectring to wav files
class WavEffector
  def initialize(file_name)
    f = open(file_name)
    @file_name = file_name
    @format = WavFile.readFormat(f)
    @data_chunk = WavFile.readDataChunk(f)
    @wav_array = wav_array
    f.close
  end

  def information
    effect = Effect.new(@wav_array)
    "#{@format}Peak:\t\t#{effect.peak}"
  end

  def normalize
    write(Normalization.new(@wav_array).run, 'normalized')
  end

  def distort
    write(Distortion.new(@wav_array).run, 'Distortion')
  end

  def overdrive
    write(Overdrive.new(@wav_array).run, 'Overdrive')
  end

  def fuzz
    write(Fuzz.new(@wav_array).run, 'Fuzz')
  end

  private

  def wav_array
    @data_chunk.data.unpack(bit_per_sample)
  end

  def bit_per_sample
    @format.bitPerSample == 16 ? 's*' : 'c*'
  end

  def write(wav_array, name)
    @data_chunk.data = wav_array.pack(bit_per_sample)
    open("#{@file_name.split('.').first}-#{name}.wav", 'w') do |out|
      WavFile.write(out, @format, [@data_chunk])
    end
  end

  # Returns file name without flie extension
  def file_name
    @file_name.split('.').first
  end
end

if ARGV[0].nil? || ARGV[1].nil?
  puts 'Usage: ruby effector.rb [Target file name] [Operation number]'
  puts 'Operation numbers:'
  puts '0. Wav Info., 1. Normalize, 2. Distort, 3. Fuzz, 4. Overdrive'
  puts '-----'
  puts "ex. Type 'ruby effector.rb sample/piano.wav 0'"
else
  effector = WavEffector.new(ARGV[0])
  case ARGV[1].to_i
  when 0
    puts effector.information
  when 1
    effector.normalize
  when 2
    effector.distortion
  when 3
    effector.fuzz
  when 4
    effector.overdrive
  else
    puts 'Operation numbers:'
    puts '0. Wav Info., 1. Normalize, 2. Distort, 3. Fuzz, 4. Overdrive'
  end
end
