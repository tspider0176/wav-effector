require 'rubygems'
require 'wav-file'

require_relative 'effects/effect'
require_relative 'effects/normalization'
require_relative 'effects/delay'
require_relative 'effects/reverb'
require_relative 'effects/distortion_effect/distortion'
require_relative 'effects/distortion_effect/overdrive'
require_relative 'effects/distortion_effect/fuzz'

# Treat effectring to wav files
class WavEffector
  def initialize(file_name)
    @file_name = file_name
  end

  def information
    effect = Effect.new(@file_name)
    "#{effect.get_format}Peak:\t\t#{effect.get_peak}"
  end

  def normalize
    Normalization.new(@file_name).write
    WavEffector.new("#{file_name}-normalized.wav")
  end

  def distort
    Distortion.new(@file_name).write
    WavEffector.new("#{file_name}-Distortion.wav")
  end

  def overdrive
    Overdrive.new(@file_name).write
    WavEffector.new("#{file_name}-Overdrive.wav")
  end

  def fuzz
    Fuzz.new(@file_name).write
    WavEffector.new("#{file_name}-Fuzz.wav")
  end

  def delay
    Delay.new(@file_name).write
    WavEffector.new("#{file_name}-Delay.wav")
  end

  def reverb
    Reverb.new(@file_name).write
    WavEffector.new("#{file_name}-Reverb.wav")
  end

  private

  # Returns file name without flie extension
  def file_name
    @file_name.split('.').first
  end
end

effector = WavEffector.new('sample/piano.wav')
puts effector.information
# effector.distortion
# effector.normalize.distortion
# effector.overdrive
# effector.normalize.overdrive
# effector.fuzz
# effector.normalize.fuzz
