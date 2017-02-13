require 'rubygems'
require 'wav-file'

require_relative 'effects/effect'
require_relative 'effects/normalization'
require_relative 'effects/distortion_effect/distortion'
require_relative 'effects/distortion_effect/overdrive'
require_relative 'effects/distortion_effect/fuzz'

class WavEffector
  def initialize(file_name)
    @file_name = file_name
  end

  def get_information
    effect = Effect.new(@file_name)
    "#{effect.get_format}Peak:\t\t#{effect.get_peak}"
  end

  def normalize
    Normalization.new(@file_name).write
    WavEffector.new("#{fileName}-normalized.wav")
  end

  def distort
    Distortion.new(@file_name).write
    WavEffector.new("#{fileName}-Distortion.wav")
  end

  def overdrive
    Overdrive.new(@file_name).write
    WavEffector.new("#{fileName}-Overdrive.wav")
  end

  def fuzz
    Fuzz.new(@file_name).write
    WavEffector.new("#{fileName}-Fuzz.wav")
  end

private
  def fileName
    "#{@file_name.split('.').first}"
  end
end

effector = WavEffector.new("sample/sample.wav")
puts effector.get_information
# effector.distortion
# effector.normalize.distortion
# effector.overdrive
# effector.normalize.overdrive
# effector.fuzz
# effector.normalize.fuzz
