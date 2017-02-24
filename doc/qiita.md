## はじめに

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

## Distortion (歪み)
### 歪みの種類について

### Distortion

### Fuzz

### Overdrive

## 実装3. Delay (反響)
### Delay
### Reverb

## まとめ

## 参考
