require 'rubygems'
require 'wav-file'

require_relative 'effects/normalization'
require_relative 'effects/distortion_effect/overdrive'

class WavEffector
  def initialize(file_name)
    @file_name = file_name
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

private
  def fileName
    "#{@file_name.split('.').first}"
  end
end

WavEffector.new("sample/sample.wav").overdrive
WavEffector.new("sample/sample.wav").normalize.overdrive
