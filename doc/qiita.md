## はじめに

ディストーションのみの説明にするか？

## 使用ライブラリ

## Digital Audio Effect (DAFX conference)
```
DAFX is a acronym for digital audio effects. It is also the name for a European research project for co-operation and scientific transfer, namely EU-COST-G6 “Digital Audio Effects” (1997-2001).
```
DAFXのカンファレンスページ [LINK](http://www.dafx.de/) から引用。
簡単に言うとデジタル音声処理の学会のこと。様々な理論がこの学会で提唱され、現在主流なプラグインに利用されている。

## Normalization (正規化)
### 正規化とは？
通常はCD、ネット上に転がってる音源等ではピーク音量は **0dB** になっているはずですが、曲によっては **0dB** に満たない曲が存在します。図に示すと以下のような感じになります。

![](./img/not-normalized.png)

もちろん「音」としてはこのままでも問題無いのですが、
音量が異常に小さいと他の音と重ね合わせる際や、別の音との音量差に気をつける必要があり、少し手間が増えます。
そのような場合に、ピーク音量を **0dB** に合わせる事で音源の正規化を行う事が出来ます。
この処理を行う事により、曲毎にバラバラな音量を整える事が出来るので聞きやすくなったりします。
例えば、上の音源を正規化すると、以下のようになります。

![](./img/normalized.png)

波形が増幅され、ピークの音量が0db(画面で言うとピッタリ)になるように調整されています。  
現在インターネット上で主流となっている効果音配布サイトやフリーの楽曲サイトでは、何か特別な理由が無い限り大抵の場合は正規化済みのものが配布されていると思われるので
正規化についてはあまり考える必要も無いのですが、
今回はまず一番簡単な実装で実現出来そうだったので取り掛かりとしてやってみましょう。

### 実装
ライブラリで紹介した wav-file の昨日にもある通り、波形を単純に二倍（音量を二倍）する時は以下のような形で実現できます。

```.rb
# 音量を半分にするプログラム
wavs = wavs.map{|w| w/2}
```

波形の正規化は、技術的には元のファイルの最大値をファイルから読み取り、その最大値をWAVファイルにおける最大値になるように変更することで実現します。
つまり、以下のプログラムで波形データから最大値を取得して

```.rb
wavs.max
```

その最大値と符号付きshortの最大値(最小値)を比率を計算し、元の *wavs* 配列の要素をその比率分だけ倍にすれば良いので、実装は以下のように書けるでしょう。

```rb
SIGNED_SHORT_MAX = "111111111111111".to_i(2)

def get_peak(wavs)
  wavs.max > wavs.min.abs ? wavs.max : wavs.min.abs
end

def normalize(wav_array)
  peak = get_peak(wav_array)
  wav_array.map{|data| data * (SIGNED_SHORT_MAX.to_f / peak)}.map(&:to_i)
end
```

get_peak関数では、最大値(最小値)を求めて返却しています。
normalize関数では、引数で渡された波形配列をmapして、直前に取得したpeak値を元に順番に波形データを増幅し、その結果を新たな配列として返却しています。実行するには例えば以下のようなプログラムを書けば良いでしょう。

```rb
f = open("input.wav")
format = WavFile::readFormat(f)
bit = format.bitPerSample == 16 ? 's*' : 'c*'
wavs = dataChunk.data.unpack(bit)

# normalize関数呼び出し
normalize(wavs)
```

### 参考
[音量の正規化(ノーマライズ:normalize)](http://www.web-sky.org/program/normalize.html)

## Distortion (歪み)
### 歪みの種類について
大きく分けてディストーションはDistortion、Fuzz、Overdriveの三つがあることを説明
三つの違いは明確なものがなく、実装する側が定義するので違いが現れることもあるが、
今回の実装ではDAFXの論文を参考に実装したことを記述。
最初にディストーションはstatic characteristic curve（特徴グラフ）で表現されることについての説明

### Distortion

```rb
def distort(peak)
    @wavs.map{|data|
      sgn(data) * (1.0 - Math.exp((-1.0) * data.abs)) * peak.to_f
    }
end
```

### Fuzz
```rb
def fuzz(peak, dist, q)
  @wavs.map{|data|
    data == (q * peak).to_i ? (((1.0/dist) + q*peak / 1 - Math.exp(dist * q*peak))).to_i : (((data - q*peak) / (1 - Math.exp((-1) * dist * (data - q*peak)))) + (q*peak / (1 - Math.exp(dist * q*peak)))).to_i
  }
end
```

### Overdrive
```rb
def overdrive(peak)
  @wavs.map{|data|
    case data.abs
    when 0..@threshold then
      2.0 * data
    when (@threshold + 1)..(@threshold * 2) then
      (3.0 - (2.0 - 3.0 * data) ** 2.0) / 3.0
    when (@threshold * 2 + 1)..(peak) then
      peak
    end
  }.map(&:to_i)
end
```

## まとめ

## 参考
