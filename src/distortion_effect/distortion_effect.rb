require_relative '../effect'

# Parent abstruct class for some distortion effects class
class DistortionEffect < Effect
  def initialize(wav_array)
    super(wav_array)
  end

  def run
    raise 'Called abstruct method'
  end
end
