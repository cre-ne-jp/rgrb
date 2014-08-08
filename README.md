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
* Redis
    * ランダムジェネレータのデータ保持に使われています。

インストール
------------

1. [Ruby](http://www.ruby-lang.org/), [Redis](http://redis.io) をインストールしていない場合はインストールしてください。
    * 別のサーバーのものを使う場合、Redis のインストールは不要。
2. [Bundler](http://bundler.io/) をインストールしていない場合は以下を実行してください。

    ```bash
    gem install bundler
    ```
3. 適当なディレクトリにファイルを設置してください。
4. 以下を実行して必要な gem（ライブラリ）をインストールしてください。

    ```bash
    cd /path/to/rgrb
    bundle install --path=vendor/bundler
    ```

設定
----

`config/rgrb.yaml` を編集して設定します。

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

# Redis の設定
Redis:
  # 接続する Redis サーバーのホスト
  Host: example.net

  # 接続する Redis サーバーのポート
  Port: 6379

  # 使用するデーターベースの番号
  Database: 0

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

IRC ボットの起動
----------------

IRC ボットを起動するには、以下を実行してください。Ctrl + C を押すと終了します。

```bash
cd /path/to/rgrb
bin/rgrb-ircbot
```

開発者向けドキュメントの生成
----------------------------

[YARD](http://yardoc.org/) を利用してライブラリのドキュメントを `doc/` 以下に生成することができます。以下を実行してください。

```bash
cd /path/to/rgrb
rake yard
```

既知の問題
----------

* IRC ボットに対して短い時間に大量のメッセージを送ると、応答が遅れます。
    * 発言内容の解析 → 応答メッセージ生成 → NOTICE はほとんど時間がかからない（0.1 μs オーダー）ため、IRC ボットのライブラリ [Cinch](https://github.com/cinchrb/cinch) が行う処理に時間がかかっている可能性があります。

ToDo
----

* [語り部](http://kataribe.jp/)のキャラクターシート検索
* Web インターフェース
    * http://kataribe.com/cgi/rg.cgi/ のようなもの

制作
----

[クリエイターズネットワーク](http://www.cre.ne.jp/)技術部

* 鯉（[@koi-chan](https://github.com/koi-chan)）
* ocha（[@ochaochaocha3](https://github.com/ochaochaocha3)）
