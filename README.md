汎用ダイスボット RGRB
=====================

RGRB とは
---------

RGRB は Ruby で実装されている汎用ダイスボットです。プラグイン方式により柔軟な拡張が可能です。

動作環境
--------

* Linux または OSX
    * 現在のところ Windows には未対応。
* Ruby 2.0.0 以降

インストール
------------

[Ruby](http://www.ruby-lang.org/) をインストールしていない場合はインストールしてください。

[Bundler](http://bundler.io/) をインストールしていない場合は以下を実行してください。

```bash
gem install bundler
```

上記が完了したら、適当なディレクトリにファイルを設置し、以下を実行して必要な gem（ライブラリ）をインストールしてください。

```bash
cd /path/to/rgrb
bundle install --path=vendor/bundler
```

設定
----

`config/rgrb.yaml` を編集して設定します。

複数の設定を使う場合は、上記のファイルをコピーして適当な場所に設置します。

```yaml
# IRC ボットの設定
IRCBot:
  # 接続する IRC サーバーのホスト名
  Host: irc.example.net

  # 接続するポート
  Port: 6667

  # パスワード。必要なければ null
  Password: pa$$word

  # ニックネーム
  Nick: rgrb_cinch

  # 接続時のユーザー名
  User: rgrb_cinch

  # リアルネーム
  RealName: 汎用ダイスボット RGRB

# 使用するプラグインを列挙する。大文字小文字を区別するので注意
Plugins:
  - DiceRoll
  - Keyword
  - RandomGenerator
```

### プラグイン一覧

* [DiceRoll](doc/plugins/dice_roll.md)：ダイスロール
* [Keyword](doc/plugins/keyword.md)：キーワード検索
* [RandomGenerator](doc/plugins/random_generator.md)：ランダムジェネレータ
* [CreTwitterCitation](doc/plugins/cre_twitter_citation.md)：Twitter @cre_ne_jp の引用
* [CreBotHelp](doc/plugins/cre_bot_help.md)：クリエイターズネットワークの IRC ボットとしてのヘルプを表示する

IRC ボットの起動
----------------

IRC ボットを起動するには、以下を実行してください。Ctrl + C を押すと終了します。

```bash
cd /path/to/rgrb
bin/rgrb-ircbot
```

`-c`（`--config`）オプションで、使用する設定ファイルを指定することができます。

```bash
cd /path/to/rgrb
bin/rgrb-ircbot -c /path/to/config_file
```

開発者向けドキュメントの生成
----------------------------

[YARD](http://yardoc.org/) を利用してライブラリのドキュメントを `doc/` 以下に生成することができます。以下を実行してください。

```bash
cd /path/to/rgrb
rake yard
```

仕様
----

* IRC ボットに対して短い時間に大量のメッセージを送ると、応答が遅れます。これは IRC サーバの負荷調整に依るものです。

ToDo
----

* Web インターフェース
    * http://kataribe.com/cgi/rg.cgi/ のようなもの

制作
----

[クリエイターズネットワーク](http://www.cre.ne.jp/)技術部

* 鯉（[@koi-chan](https://github.com/koi-chan)）
* ocha（[@ochaochaocha3](https://github.com/ochaochaocha3)）
* らぁ（[@raa0121](https://github.com/raa0121)）
* risou（[@risou](https://github.com/risou)）
