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
    WavEffector.new("#{@file_name.split('.').first}-normalized.wav")
  end

  def distort()
    Distortion.new(@file_name).write
    WavEffector.new("#{@file_name.split('.').first}-distorted.wav")
  end
end

WavEffector.new("sample/sample.wav").normalize
WavEffector.new("sample/sample.wav").distort
WavEffector.new("sample/sample.wav").normalize.distort
