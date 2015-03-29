汎用 IRC ボット RGRB
=====================

[![Build Status](https://travis-ci.org/cre-ne-jp/rgrb.svg?branch=master)](https://travis-ci.org/cre-ne-jp/rgrb) [![Coverage Status](https://coveralls.io/repos/cre-ne-jp/rgrb/badge.svg?branch=master)](https://coveralls.io/r/cre-ne-jp/rgrb?branch=master)

RGRB は Ruby で実装されている汎用 IRC ボットです。プラグイン方式により柔軟な拡張が可能です。

動作環境
--------

* Linux または OSX
    * 現在のところ Windows には未対応。
* Ruby 2.1.0 以降

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
bundle install --deployment
```

設定
----

[config/rgrb.yaml](config/rgrb.yaml) を編集して設定します。

複数の設定を使う場合は、上記のファイルをコピーして config/ に設置します。

### プラグイン一覧

#### オンラインセッション支援

| プラグイン名 | 内容 |
| ------------ | ---- |
| [DiceRoll](doc/plugins/dice_roll.md) | ダイスロール |
| [RandomGenerator](doc/plugins/random_generator.md) | ランダムジェネレータ |
| [Trpg::Detatoko](doc/plugins/trpg/detatoko.md) | 「でたとこサーガ」専用のダイス・表引きコマンド |

#### 情報検索・引用

| プラグイン名 | 内容 |
| ------------ | ---- |
| [Keyword](doc/plugins/keyword.md) | キーワード検索 |
| [OnlineSessionSearch](doc/plugins/online_session_search.md) | [TRPG.NET セッションマッチングシステム](http://session.trpg.net/)から予定されているオンラインセッションの情報を検索する |
| [CreTwitterCitation](doc/plugins/cre_twitter_citation.md) | Twitter @cre_ne_jp の引用 |

#### IRC 関連

| プラグイン名 | 内容 |
| ------------ | ---- |
| [CreBotHelp](doc/plugins/cre_bot_help.md) | クリエイターズネットワークの IRC ボットとしてのヘルプを表示する |
| [ServerConnectionReport](doc/plugins/server_connection_report.md) | IRC サーバの接続状態の変化を報告する |
| [Part](doc/plugins/part.md) | チャンネルからの退出 |

IRC ボットの起動
----------------

IRC ボットを起動するには、以下を実行してください。Ctrl + C を押すと終了します。

```bash
cd /path/to/rgrb
bin/rgrb-ircbot
```

`-c`（`--config`）オプションで、使用する設定ファイルを指定することができます。`-c` に続けて、config/ に配置した YAML ファイルの、ファイル名から拡張子を除いた部分を指定します。

```bash
cd /path/to/rgrb
bin/rgrb-ircbot -c test # /path/to/rgrb/config/test.yaml を使用する場合
```

systemd による制御を行なう場合は [systemd](doc/system/systemd.md) を参照してください。

開発者向けドキュメントの生成
----------------------------

[YARD](http://yardoc.org/) を利用してライブラリのドキュメントを [doc/](doc/) 以下に生成することができます。以下を実行してください。

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

連絡先
------

ご意見・ご要望・バグ報告等は、[irc.cre.jp 系 IRC サーバ群](http://www.cre.ne.jp/services/irc)の IRC チャンネル「#cre」や、[GitHub リポジトリ](https://github.com/cre-ne-jp/rgrb)上の「[Issues](https://github.com/cre-ne-jp/rgrb/issues)」・「[Pull Requests](https://github.com/cre-ne-jp/rgrb/pulls)」にて承っております。お気軽にお寄せください。

ライセンス
----------

[MIT License](LICENSE)（[日本語](LICENSE.ja)）

制作
----

&copy; 2014-2015 [クリエイターズネットワーク](http://www.cre.ne.jp/)技術部

* 鯉（[@koi-chan](https://github.com/koi-chan)）
* ocha（[@ochaochaocha3](https://github.com/ochaochaocha3)）
* らぁ（[@raa0121](https://github.com/raa0121)）
* risou（[@risou](https://github.com/risou)）
