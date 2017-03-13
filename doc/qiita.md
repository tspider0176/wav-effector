## はじめに

## 環境と使用ライブラリ
```
$ ruby -v
ruby 2.2.3p173 (2015-08-18 revision 51636)
```

* wav-file (gem)

## Digital Audio Effect (DAFX conference)
```
DAFX is a acronym for digital audio effects. It is also the name for a European research project for co-operation and scientific transfer, namely EU-COST-G6 “Digital Audio Effects” (1997-2001).
```

DAFXのカンファレンスページ [LINK](http://www.dafx.de/) から引用。DAFXは簡単に言うとデジタル音声処理の学会のことです。様々な理論がこの学会で提唱され、実際のソフトウェアに利用されています。
トップページには検索フォームと各年度毎に開催された学会の詳細ページへのリンクがずらっと並んでいます。凝ってて綺麗。  
![](./img/dafx_top.png)

これは余談ですが、各年度の学会のページを眺めると、載っている学会のスポンサー企業がすごい豪華です。DTMをやっている人であればどの企業も一度は聞いたことのある企業ばかりでした。(この中で自分はiZotope社のプラグインを使用しているのでとても驚きました)  
この学会で発表された理論を元に、自分の手元にあるプラグインが作られているのかと考えると、なかなか興味深いです。
![](./img/sponsors.png)

## 0. Normalization (正規化)
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


## 1. Distortion (歪み)
### 1.1 エフェクトとしての「歪み」の種類
大きく分けてディストーションエフェクトにはDistortion、Fuzz、Overdriveの三つがあります。
三つの違いは明確なものがなく、実装する側が定義するので違いが現れることもありますが、今回の実装ではDAFXの論文を参考に実装しました。
最初にディストーションはstatic characteristic curve（特徴グラフ）で表現されます。DAFX論文集に従うと、
* Distortion  
指数的に滑らかに増幅

* Fuzz  
一定の値を区切りに出力を固定/増幅

* Overdrive  
ある一定の値を超えた所で過度に増幅

と特徴があります。

### 1.2 Distortion
Distortionエフェクトの数式での定義は以下になります。

```rb
def distort(peak)
    @wavs.map{|data|
      sgn(data) * (1.0 - Math.exp((-1.0) * data.abs)) * peak.to_f
    }
end
```

### 1.3 Fuzz
#### 1.3.1 説明
Fuzzという単語には「毛羽立った」という意味があり、その意味の通り原音を過剰に歪ませるエフェクトになります。
今回実装する歪み系エフェクトの中ではもっとも歴史が古く、過去のジミ・ヘンドリックスを始めとする偉大なギタリスト達が、強烈な音を求めた末に編み出した音でした。
技術的な説明をすると、アンプに過剰な入力を与えることによって発生する原音には無い倍音を付加させるエフェクトです。
しかしこの手法では、アンプに対して想定されていないような過剰な負荷をかけて演奏することになるので、アンプの機材の寿命を著しく縮めます。
そこで登場したのが意図的に過剰な歪みを発生させるエフェクター、Fuzz faceでした。
今回はDAFXの論文に従って、模擬的なFuzzエフェクトを発生させてみます。

#### 1.3.2 実装
今回実装するFuzzエフェクトの数式での定義は以下になります。

```rb
def fuzz(peak, dist, q)
  @wavs.map{|data|
    data == (q * peak).to_i ? (((1.0/dist) + q*peak / 1 - Math.exp(dist * q*peak))).to_i : (((data - q*peak) / (1 - Math.exp((-1) * dist * (data - q*peak)))) + (q*peak / (1 - Math.exp(dist * q*peak)))).to_i
  }
end
```

### 1.4 Overdrive
#### 1.4.1 説明
オーバードライブは【アンプのボリュームを上げ出力電圧を加えて回路が飽和して出力音が歪んでしまう】状態のことで、もともとは1950年代当時のクリーントーンしか出なかったギターアンプのボリュームを上げすぎた時に偶然見つかった現象でした。エフェクターのオーバードライブはこの歪みを意図的にシミュレーションしたもので、回路内にクリッピングのダイオードを使用します。(引用)
今回はプログラム上で、数式で表現されたオーバードライブエフェクトを実現します。

#### 1.4.2 実装
実際の数式での定義を見てみましょう。

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
この記事はAIZU AVENT CALENDAR 2016 で書いた記事から発展して取り組んだ内容になりました。
今までサウンドプログラミングには全く触れてきませんでしたが、趣味と自分の大学生活で身につけた技術双方を取り入れる事が出来てとても楽しかったです。
論文については専門外なので論文を書くことは無いでしょうが、論文を読む良い練習にもなりました（この記事を出す頃にはとっくに卒論は書き終わってますが…）
これからも興味のある論文を見付けたら積極的に読み、可能であれば実装していきたいと思います。


## 参考
* [橋本商会 >> wavファイルをRubyで編集する](http://shokai.org/blog/archives/5408)  
* [音量の正規化(ノーマライズ:normalize)](http://www.web-sky.org/program/normalize.html)
