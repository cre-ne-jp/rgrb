BCDice
========

100種類以上のゲームシステムに対応しているダイスエンジン「[ボーンズ＆カーズ](https://bcdice.org)」（以下、BCDice）を使えるようにするためのプラグインです。

現在はダイスロール機能のみ使用できます。
従来のBCDiceに備わっていた機能のうち、以下に示す機能は実装されていません。

* マスターコマンド
* チャンネルごとの設定保存
* プロット
* ポイントカウンタ
* カード

コマンド
--------

### ダイスロール

#### 書式

```
.bcdice <command> <gameSystemID>
```

#### 説明

BCDiceのダイスコマンドを実行します（ダイスを振ります）。

BCDiceの書式にあわせて、_command_ を記述してください。
その際、_gameSystemID_ にゲームシステムIDを指定すると、BCDiceが対応しているTRPGシステム固有のコマンドも実行できます。
存在しないゲームシステムIDを指定した場合はエラーとなります。

#### 例

```
.bcdice 2d6
> BCDice->foo[DiceBot]: (2D6) ＞ 7[1,6] ＞ 7

.bcdice K20@8 SwordWorld2_0
> BCDice->koi-chan[away][SwordWorld2.0]: KeyNo.20c[8] ＞ 2D:[6,4 6,4 6,5 4,3]=10,10,11,7 ＞ 8,8,9,5 ＞ 3回転 ＞ 30
```

### ゲームシステム一覧

#### 書式

```
.bcdice-systems
```

#### 説明

[BCDice公式サイトの対応ゲームシステム一覧ページ](https://bcdice.org/systems/)のURLを出力します。
次に示すゲームシステム検索機能とともに、ゲームシステムのIDを探したい場合に活用してください。

#### 例

```
.bcdice-systems
> BCDice ゲームシステム一覧 https://bcdice.org/systems/
```

### ゲームシステム検索

#### 書式

ゲームシステムIDで検索：

```
.bcdice-search-id <keyword>
```

ゲームシステム名で検索：

```
.bcdice-search-name <keyword> [<keyword> ...]
```

#### 説明

指定された _keyword_ を含むゲームシステムの一覧を表示します。
`.bcdice-search-id` はゲームシステムIDを基準として、`.bcdice-search-name` はゲームシステム名を基準として検索します。

ゲームシステム名を基準とする場合は、半角空白または全角空白で区切って複数のキーワードを指定することが可能です。
その場合は、ゲームシステム名にすべてのキーワードが含まれるゲームシステムの一覧を表示します。

#### 例

以下はIRCボットで使用した場合の出力例です。
Discordボットで使用した場合は、複数行で出力されます。

```
.bcdice-search-id gun
> BCDice ゲームシステム検索結果 (ID: gun): Gundog (ガンドッグ), GundogRevised (ガンドッグ・リヴァイズド), GundogZero (ガンドッグゼロ), TwilightGunsmoke (トワイライトガンスモーク)

.bcdice-search-name ソード
> BCDice ゲームシステム検索結果 (名称: ソード): SwordWorld (ソード・ワールドRPG), SwordWorld2.0 (ソード・ワールド2.0), SwordWorld2.5 (ソード・ワールド2.5)

.bcdice-search-name TRPG クトゥルフ
> BCDice ゲームシステム検索結果 (名称: TRPG クトゥルフ): Cthulhu (クトゥルフ神話TRPG), Cthulhu7th (新クトゥルフ神話TRPG)

.bcdice-search-name TRPG クトゥルフ　新
> BCDice ゲームシステム検索結果 (名称: TRPG クトゥルフ 新): Cthulhu7th (新クトゥルフ神話TRPG)
```

### バージョン出力

#### 書式

```
.bcdice-version
```

#### 説明

使用しているBCDiceのバージョンを出力します。

#### 例

```
.bcdice-version
> BCDice Version: 3.2.0
```

ToDo
----

* チャンネル別に使っているゲームタイプを保存する
* プロット機能を使えるようにする
* ゲーム専用ダイスでしか使われていない特殊記号がないか確認する
