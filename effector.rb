require 'rubygems'
require 'wav-file'

require_relative 'effects/normalization'
require_relative 'effects/distortion'

class WavEffector
  def initialize(file_name)
    @file_name = file_name
  end

  def normalize()
    Normalization.new(@file_name).write
    WavEffector.new("#{fileName}-normalized.wav")
  end

  def distort(algorithm)
    Distortion.new(@file_name, algorithm).write
    WavEffector.new("#{fileName}-distorted.wav")
  end

private
  def fileName
    "#{@file_name.split('.').first}"
  end
end

WavEffector.new("sample/sample.wav").distort('fuzz')
WavEffector.new("sample/sample.wav").normalize.distort('fuzz')
