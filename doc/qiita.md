## はじめに

ディストーションのみの説明にするか？

## 使用ライブラリ

## Digital Audio Effect (DAFX conference)
```
DAFX is a acronym for digital audio effects. It is also the name for a European research project for co-operation and scientific transfer, namely EU-COST-G6 “Digital Audio Effects” (1997-2001).
```
DAFXのカンファレンスページ [LINK](http://www.dafx.de/) から引用。
簡単に言うとデジタル音声処理の学会のこと。様々な理論がこの学会で提唱され、現在主流なプラグインに利用されている。

## クラス構造

## Normalization (正規化)
### 正規化とは？
通常は CD 等ではピーク音量は **0dB** になっているはずですが曲によっては 0dB に満たない曲が存在します。
その場合にピーク音量を **0dB** に合わせる事で平均化を行う事が出来ます。
この処理を行う事によって曲毎にバラバラな音量を整える事が出来るので聞きやすくなったりします。

### 実装
ライブラリで紹介した wav-file の昨日にもある通り、波形を単純に二倍（音量を二倍）する時は以下のような形で実現できる。

```.rb
# 音量を半分にするプログラム
wavs = wavs.map{|w| w/2}
```

波形の正規化は、技術的には元のファイルの最大値をファイルから読み取り、その最大値をWAVファイルにおける最大値になるように変更することで実現する。
つまり、以下のプログラムで波形データから最大値を取得して

```.rb
wavs.max
```

その最大値と符号付きshortの最大値(最小値)を比率を計算し、元の *wavs* 配列の要素をその比率分だけ倍にすれば良いので、実装は以下のように書けるだろう。

```
SIGNED_SHORT_MAX = "111111111111111".to_i(2)

def normalizee(wav_array)
  wav_array.map{|data| data * (SIGNED_SHORT_MAX.to_f / @peak)}.map(&:to_i)
end
```

! 上は最大値のみ考慮されてるので、最小値も考慮する必要がある

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
