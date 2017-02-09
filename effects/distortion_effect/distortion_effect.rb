require_relative '../effect'

class DistortionEffect < Effect
  def initialize(file_name)
    super(file_name)
  end

  def write
    @data_chunk.data = run.pack(bit_per_sample)

    open("#{@file_name.split('.').first}-#{class_name}.wav", "w"){|out|
      WavFile::write(out, @format, [@data_chunk])
    }
  end

private
  def class_name
    self.class.to_s
  end
end
