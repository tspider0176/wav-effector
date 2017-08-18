## はじめに

本記事内では波形の確認にフリーの非破壊サウンド編集ソフト、Audacityを使っていますが、あくまでも波形を表示するための一般的なツールとして用いているので、本稿ではソフトについての説明はしません。

この記事は[前の記事(Rubyを使ったWAVファイルのBPM解析)](http://qiita.com/stringamp/items/35ea7cca7a70f99f8de3)を書く上で学んだ知識を元に進めています。よかったらこちらもどうぞ。

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

記事に使われたソースコード全体は以下のリンクからどうぞ。
[GitHubリポジトリ](https://github.com/tspider0176/wav-effector)


DAFXのカンファレンスページ [LINK](http://www.dafx.de/) から引用。DAFXは簡単に言うとデジタル音声処理の学会のことです。様々な理論がこの学会で提唱され、色々な音声処理のソフトウェアに利用されています。
トップページには検索フォームと各年度毎に開催された学会の詳細ページへのリンクがずらっと並んでいます。
<img width="837" alt="dafx_top.png" src="https://qiita-image-store.s3.amazonaws.com/0/146476/0b5da73a-88e4-02b5-12ad-a729b3f2aca2.png">

本稿では、この学会で実際に発表された理論を元に実装を進めていきたいと思います。

## 0. Normalization (正規化)
### 正規化とは？
通常はCD、ネット上に転がってる音源等ではピーク音量は **0dB** になっているはずですが、曲によっては **0dB** に満たない曲が存在します。そのような音源をAudacityで開いた場合、以下のような画面になります。

<img width="919" alt="not-normalized.png" src="https://qiita-image-store.s3.amazonaws.com/0/146476/cfd21467-d04d-91d7-c910-2c1e8654db96.png">

もちろん「音」を聞く分にはこのままでも問題無い（聞き手が音量を上げれば良い）のですが、
音量が異常に小さいと、例えば他の音と重ね合わせる際や別の音との音量差に気をつける必要があり、手間が少し増えます（聞いていた曲の音量が小さくて音量MAXにしていたら、次に流れた曲が異様に音圧の高い曲で、耳が殺られた経験されたことある方も居るのでは）
そのような場合、ピーク音量を **0dB** に合わせる事で音源の **正規化** を行う事が出来ます。
正規化を行うことにより、曲毎にバラバラな音量を整える事が出来るので聞きやすくなったりします。
例えば、上の音源を正規化すると、波形は以下のようになります。

<img width="914" alt="normalized.png" src="https://qiita-image-store.s3.amazonaws.com/0/146476/8f149306-c621-d562-aebb-400695f7333d.png">

波形が増幅され、ピークの音量が0db(画面で言うと1.0ピッタリ)になるように調整されています。  
現在インターネット上に多く存在する効果音配布サイトやフリーの楽曲サイトでは、特別な理由が無い限り正規化済みのものが配布されていると思われるので、正規化についてはあまり考える必要も無いのですが、
今回はまず一番簡単な実装で、音声処理の取り掛かりとしてすぐ実現出来そうだったのでやってみます。

### 実装
使用しているライブラリで紹介した *wav-file* の[実行例](http://shokai.org/blog/archives/5408)にもある通り、波形を単純に半分（音量を半分）する時は以下のような形で実現できます。

```.rb
# 音量を半分にするプログラム
wavs = wavs.map{|w| w/2}
```

波形の正規化は、技術的には元のファイルの最大値(最小値)をファイルから読み取り、その最大値(最小値)をWAVファイルにおける最大値(最小値)になるように変更することで実現します。
つまり、以下のプログラムで波形データから最大値と最小値の絶対値を取得して、

このような形にすれば良さそうです。
その最大値と符号付きshortの最大値との比率を計算し、元の *wavs* 配列の要素をその比率分だけ倍にすれば良いので、実装は以下のように書けるでしょう。

```rb
SIGNED_SHORT_MAX = "111111111111111".to_i(2)

def get_peak(wavs)
  [wavs.max, wavs.min.abs].max
end

def normalize(wav_array)
  peak = get_peak(wav_array)
  wav_array.map{|data| data * (SIGNED_SHORT_MAX.to_f / peak)}.map(&:to_i)
end
```

get_peak関数では、最大値(最小値の絶対値)を求めて返却しています。
normalize関数では、引数で渡された波形配列をmapして、直前に取得したpeak値を元に順番に波形データを増幅し、その結果を新たな配列として返却しています。  
実行するには以下のようなプログラムを書けば良いでしょう。

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
三つの違いは明確なものがなく、実装する側が定義するので違いが現れることもありますが、今回の実装ではDAFXの論文に載っている定義を元に実装しました。  
最初に、ディストーションはstatic characteristic curve(特徴グラフ)と呼ばれるもので表現されます。DAFXに記載されている論文、「Nonlinear Processing」を見てみると、

* Distortion  

<img width="517" alt="スクリーンショット 2017-08-16 22.48.13.png" src="https://qiita-image-store.s3.amazonaws.com/0/146476/2f59e9c1-3233-4b1b-25f3-99cb3bc54d57.png">

指数的に滑らかに増幅

* Fuzz  

<img width="611" alt="スクリーンショット 2017-08-16 22.46.12.png" src="https://qiita-image-store.s3.amazonaws.com/0/146476/5bfe21fc-801d-7b37-5496-2b82cfabd946.png">

一定の値を区切りに出力を固定又は増幅

* Overdrive  

<img width="634" alt="スクリーンショット 2017-08-16 22.46.45.png" src="https://qiita-image-store.s3.amazonaws.com/0/146476/fd376185-cafd-3e1d-fabe-fb7b370d5761.png">

ある一定の値を超えた所で極端に増幅

と行った特徴があります。

### 1.2 Distortion(エフェクト)
#### 1.2.1 説明
```
音響機器におけるディストーション (distortion)とは、広義には音像の歪み(ひずみ)、またその歪んだ音色そのものを指す。  
狭義のディストーションはエレキギターで最も多用されるが、エレキベース、電子オルガン等にも利用される他、ボーカルのエフェクトとして用いられる場合もある。(Wikipedia引用)
```

Wikipediaにも書いてある通り、入力を増幅回路で増幅させた後に、増幅させ過ぎてピークをはみ出た部分を無理やりピークで揃えることで元の音に倍音成分を付与するエフェクト方式のことみたいです。Wikiにとてもわかりやすい図が置いてあったので引用します。

<img width=70% alt="def_distortion.png" src="https://upload.wikimedia.org/wikipedia/commons/c/ca/Clipping_waveform.svg">

例えば16bitのWAVファイルでは、表現可能な数値は符号あり16bitの範囲-32767〜32768となっています。
上の図で言うHard Clippingは、上限である32768を超える(もしくは下限である-32767を下回る)入力があった場合、自動的に32768(または-32767)に揃えて波形を出力すれば実現できそうです。

#### 1.2.2 実装
Distortionの中に更にDistortionという同じ名前のエフェクト効果があって紛らわしいですが、Distortionエフェクトの数式での定義は以下になります。  
<img width=30% alt="def_distortion.png" src="https://qiita-image-store.s3.amazonaws.com/0/146476/ae92780b-ed27-cce5-2d48-f5af46e21e25.png">

また、実装は以下のように書けるでしょう。

(※8/18修正)
```rb
def distort(peak)
  @wavs.map{|data|
    x = data.fdiv(peak)
    y = sgn(x) * (1.0 - Math.exp(-5.0 * x.abs))
    (y * SIGNED_SHORT_MAX).to_i
  }
end
```

#### 1.2.3 実行
実際に適当な音声ファイルに適用してみましょう。
Distortionを実行するには第4コマンドライン引数に2を指定します。

```
$ ruby effector.rb sample/piano.rb 2
```

元の音声ファイルはsample内に入っている *piano.wav* を使用。
<img width="918" alt="piano.png" src="https://qiita-image-store.s3.amazonaws.com/0/146476/490d4531-5f5d-5414-f911-9ea34e1d504f.png">

この波形が

<img width="916" alt="piano-dist.png" src="https://qiita-image-store.s3.amazonaws.com/0/146476/28d26369-ba78-b177-8849-4b4175798ce0.png">

めっちゃソーセージに。あれ〜？
少し調べてみたのですが、論文内で引用されている数式に誤植があるようで、少し調べまわってみたのですが正しい数式が見つからず…残念な結果になってしまいました。
元の音階は辛うじて聞き取れるレベルですが、ここまで増幅されちゃうと最早別物ですね。
実際に聴いてみましたが、ニコニコ動画で音量注意を毎日食らってる自分でも聞くに耐えないうるささだったので非推奨。  

**(※8/18追記)**  
コメント欄にて、@HMMNRST さんより数式の改善点とプログラム上の問題を指摘していただきました！  
上記のプログラムでは `@wavs` に対するmap操作中で、 `data` の範囲が考慮されていなかったので、以下のように修正すれば適切に動くようになります。
誤植が見受けられた数式についても、

![](./img/def_distortion_fix.png)

にて A=5 の場合を考えれば適切に出力されます。実際に実行した結果は以下のようになります。

![](./img/piano-dist-fix.png)

元波形にとてもいい感じにディストーションがかかっていて感動しました…。三つの音の中では一番好きかも。
ご指摘ありがとうございましたm(_ _)m


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

<img width="431" alt="fuzz.png" src="https://qiita-image-store.s3.amazonaws.com/0/146476/a5cf31b2-896f-0aad-d38f-47c95d54e434.png">

```rb
def fuzz(peak, dist, q)
  @wavs.map{|data|
    data == (q * peak).to_i ? (((1.0/dist) + q*peak / 1 - Math.exp(dist * q*peak))).to_i : (((data - q*peak) / (1 - Math.exp((-1) * dist * (data - q*peak)))) + (q*peak / (1 - Math.exp(dist * q*peak)))).to_i
  }
end
```

ある値(上の数式ではQ)を超えると、一定の値が出力されるような式になっています。

#### 1.3.3 実行
こちらも実際に適当な音声ファイルに適用してみましょう。
Fuzzを実行するには第4コマンドライン引数に3を指定します。

```
$ ruby effector.rb sample/piano.rb 3
```

元の音声ファイルは同じくsample内に入っている *piano.wav* を使用。

<img width="918" alt="piano.png" src="https://qiita-image-store.s3.amazonaws.com/0/146476/490d4531-5f5d-5414-f911-9ea34e1d504f.png">

上の波形が、

<img width="917" alt="piano-fuzz.png" src="https://qiita-image-store.s3.amazonaws.com/0/146476/554ba59a-96bf-eefa-edf2-4fc99e02c690.png">

見事に閾値以下がすっぱり切られた波形へと変換されました。どうやらちゃんと動いているようです。
単純に閾値以下を削って若干変更しただけですが、音には変化がありました。  
実際に聴いてみるとギンギンしたちょっとうるさい音に変化してました。これが毛羽立った音…。

### 1.4 Overdrive
#### 1.4.1 説明
オーバードライブは【アンプのボリュームを上げ出力電圧を加えて回路が飽和して出力音が歪んでしまう】状態のことで、もともとは1950年代当時のクリーントーンしか出なかったギターアンプのボリュームを上げすぎた時に偶然見つかった現象でした。エフェクターのオーバードライブはこの歪みを意図的にシミュレーションしたもので、回路内にクリッピングのダイオードを使用します。(引用)
今回はプログラム上で、数式で表現されたオーバードライブエフェクトを実現します。

#### 1.4.2 実装
Overdriveの特徴グラフを示す数式を見てみると、以下のようになります。

<img width=50% alt="def_overdrive.png" src="https://qiita-image-store.s3.amazonaws.com/0/146476/15496665-39fa-6147-7bc4-9dc096949ba4.png">

以下のようにcase式でチャチャっと実装してしまいます。

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

#### 1.4.3 実行
こちらも実際に適当な音声ファイルに適用してみましょう。
Overdriveを実行するには第4コマンドライン引数に4を指定します。

```
$ ruby effector.rb sample/piano.rb 4
```

元の音声ファイルは同じくsample内に入っている *piano.wav* を使用。

<img width="918" alt="piano.png" src="https://qiita-image-store.s3.amazonaws.com/0/146476/490d4531-5f5d-5414-f911-9ea34e1d504f.png">

上の波形が、

<img width="915" alt="piano-od.png" src="https://qiita-image-store.s3.amazonaws.com/0/146476/f78130b6-00ea-7b97-3161-c0cefe752f3c.png">

このような波形に出力されました。数式からもわかる通り、thresholdを基準にそれぞれの帯域で異なる数式を当てはめたので、閾値を超える部分では一気に波形が増幅されてピークにべったり張り付いてるのが確認できます。  
実際に聞いてみましたがメッチャうるさかったです。もうちょっと常識的なうるささになってほしい。


## まとめ
この記事はAIZU AVENT CALENDAR 2016 で書いた記事から発展して取り組んだ内容になりました。
今までの学生生活では、講義はもちろん自主的な学習でもサウンドプログラミングには全く触れてきませんでしたが、趣味と自分の大学生活で身につけた技術双方を取り入れる事が出来る分野が見つかってとても楽しかったです。
専門外なのでDAFXの要な論文を書くことは無いでしょうが、論文を読む良い練習にもなりました。
これからも興味のある論文を見付けたら積極的に読み、可能であれば実装していきたいと思います。
(rubocopに実装が怒られている部分があるので次の実装の前にリファクタリングを学ばなければいけなさそうです)

これは余談ですが、DAFXの各年度の学会のページを眺めてみると、載っている学会のスポンサー企業がすごい豪華でした。(この中で自分はiZotope社のプラグインを愛用しているのでとても驚きました)  
この学会で発表された理論を元に、自分の手元にあるプラグインが作られているのかと考えると、なかなか興味深いです。今後も色々と調べて行きたいですね。
<img width=80% alt="sponsors.png" src="https://qiita-image-store.s3.amazonaws.com/0/146476/b6ef9429-ff43-9425-5793-7e81bdc5f7ce.png">


## 参考
* [橋本商会 >> wavファイルをRubyで編集する](http://shokai.org/blog/archives/5408)  
* [音量の正規化(ノーマライズ:normalize)](http://www.web-sky.org/program/normalize.html)
* [DAFX](http://www.dafx.de/)
