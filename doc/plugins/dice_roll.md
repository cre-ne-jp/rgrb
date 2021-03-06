DiceRoll
========

ダイスロールを行えるようにするプラグインです。

コマンド
--------

### ダイスロール

#### 書式

```
.roll <f>d<p>
.roll <f>D<p>
。<●>の<▼>
```

#### 説明

面数 _p_ のダイスを _f_ 個振ったときの合計値を返します。

スマートフォンなどのIRCクライアントからダイスが振りやすくなるよう、日本語のダイスコマンドが実装されています。こちらは、面数 _●_ のダイスを _▼_ 個振ったときの合計値を返します。あ段のひらがな「あかさたなはまやらわ」が、それぞれ数字「1234567890」に相当しています。

![ひらがなと数字の対応](images/dice-roll-ja.png "ひらがなと数字の対応")

#### 例

```
.roll 2d6
> foo -> 2d6 = [6,2] = 8
.roll 1D6
> foo -> 1d6 = [1] = 1
。かのは
> foo -> 2d6 = [3,4] = 7
```

### dXX ロール

#### 書式

```
.roll d<XX>
。の<○○>
```

#### 説明

出目をそのまま並べて数字にするダイスロールの結果を返します。_XX_ に入れた各数字をダイス面数として、桁数の分だけそのダイスを振ります。

_XX_ には 1～20 桁の数字を指定します。ただし、途中に 0 を入れると、0 を含めそれより後ろの数字を無視します。

日本語ダイスコマンドを使う場合のひらがな→数字の対応は、上記の通常のダイスロールと同じです。

![ひらがなと数字の対応](images/dice-roll-ja.png "ひらがなと数字の対応")

#### 例

```
.roll d66
> foo -> d66 = [3,6] = 36
.roll d567
> foo -> d567 = [3,2,7] = 327
。のはは
> foo -> d66 = [5,6] = 56
```

### シークレットロール

#### 書式

```
.sroll 2d6
.sroll d66
.sroll-open
```

#### 説明

上記のどちらのコマンドも、`.roll` を `.sroll` に置き換えることで、シークレットロールに出来ます。

チャンネルでシークレットロールコマンドを発言すると、トークでダイス結果を本人だけに知らせます。  
トークでシークレットロールコマンドを発言すると、シークレットロールを開けるまで誰にも結果は分かりません。

どちらも、シークレットロールを開けるコマンドは、シークレットロールコマンドを発言したチャンネル(もしくはトーク)だけで有効です。

#### 例

```
(#channel) .sroll 2d6
(#channel) > foo: シークレットロールを保存しました
(talk) > チャンネル #channel でのシークレットロール: foo -> 2d6 = [2,4] = 6
(#channel) .sroll d66
(#channel) > foo: シークレットロールを保存しました
(talk) > チャンネル #channel でのシークレットロール: foo -> d66 = [1,5] = 15
(#channel) .sroll-open
(#channel) > #channel のシークレットロール: 2 件
(#channel) > foo -> 2d6 = [2,4] = 6
(#channel) > foo -> d66 = [1,5] = 15
(#channel) > シークレットロールここまで

(talk) .sroll d66
(talk) > シークレットロールを保存しました
(talk) .sroll 2d6
(talk) > シークレットロールを保存しました
(talk) .sroll-open
(talk) > foo のシークレットロール: 2 件
(talk) > foo -> d66 = [6,5] = 65
(talk) > foo -> 2d6 = [1,2] = 3
(talk) > シークレットロールここまで

```


設定
----

設定ファイルに以下を追加して、プラグインの設定を行います。

```yaml
# ダイスロールプラグインの設定
DiceRoll:
  # 日本語ダイス機能を有効化するか
  # false (無効)以外の文字を入力すると true (有効)として扱う
  JaDice: false
  # 多すぎるダイスロールをした時、机ではなく荷台からダイスが落ちる確率
  # 1 - 1000 で指定してください。初期値は 100 、0 を指定すると無効化します
  FallOffTrack: 100
```

ToDo
----

* 「[ボーンズ＆カーズ](https://github.com/torgtaitai/BCDice)」 並みにダイスロールの種類を増やす？
