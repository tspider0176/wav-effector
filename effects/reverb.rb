require_relative './effect'

class Reverb < Effect
  def initialize(file_name)
    super(file_name)
  end

  def run
    reverb(10, 3000, 0.5)
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

  def delay_arr(delay_time, n)
    delay_sample = [0] * delay_time
    (delay_sample * n) + @wavs
  end

  def zero_arr(n)
    [0] * n
  end

  def reverb(delay_num, delay_time, decay_rate)
    peak = get_peak
    resized = @wavs + zero_arr(delay_time * delay_num)

    init_arr = zero_arr(@wavs.length + delay_time * delay_num)

    delay = (1..delay_num).map{|i|
      delay_arr(delay_time, i).map{|data|
        data.to_f * (decay_rate ** i)
      } + zero_arr(delay_time * (delay_num - i))
    }.inject(init_arr){|acc, arr| acc.zip(arr).map{|a, b| (a + b).to_i}}

    resized.zip(delay).map{|a,b| a + b > peak ? peak : a + b}
  end
end
