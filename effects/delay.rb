require_relative './effect'

class Delay < Effect
  def initialize(file_name)
    super(file_name)
  end

  def run
    delay(6, 20000, 0.6)
  end

  def write
    @data_chunk.data = run.pack(bit_per_sample)
    open("#{@file_name.split('.').first}-delayed.wav", "w"){|out|
      WavFile::write(out, @format, [@data_chunk])
    }
  end

private
  def delay_arr(delay_time, n)
    delay_sample = [0] * delay_time
    (delay_sample * n) + @wavs
  end

  def zero_arr(n)
    [0] * n
  end

  def delay(delay_num, delay_time, decay_rate)
    resized = @wavs + zero_arr(delay_time * delay_num)

    init_arr = zero_arr(@wavs.length + delay_time * delay_num)

    resized + (1..delay_num).map{|i|
      delay_arr(delay_time, i).map{|data|
        data * (decay_rate ** i)
      } + zero_arr(delay_time * (delay_num - i))
    }.inject(init_arr){|acc, arr| acc.zip(arr).map{|a, b| a + b}}
  end
end
