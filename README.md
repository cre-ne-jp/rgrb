汎用チャットボット RGRB
====================

![Test](https://github.com/cre-ne-jp/rgrb/workflows/Test/badge.svg)
[![Maintainability](https://api.codeclimate.com/v1/badges/ee60ffa7fe19fbb3147b/maintainability)](https://codeclimate.com/github/cre-ne-jp/rgrb/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/ee60ffa7fe19fbb3147b/test_coverage)](https://codeclimate.com/github/cre-ne-jp/rgrb/test_coverage)

RGRB は Ruby で実装されている汎用 IRC/Discord ボットです。プラグイン方式により柔軟な拡張が可能です。

動作環境
--------

* Linux または OSX
    * 現在のところ Windows には未対応。
* Ruby 3.0 以降

インストール
------------

[Ruby](http://www.ruby-lang.org/) をインストールしていない場合はインストールしてください。

[Bundler](http://bundler.io/) をインストールしていない場合は以下を実行してください。

```bash
gem install bundler
```

上記が完了したら、適当なディレクトリにファイルを設置し、以下を実行して必要な gem（ライブラリ）をインストールしてください。

なお、gem をインストールするためには、システムにいくつかのライブラリと開発環境がインストールされている必要があります。CentOS 7 を最小限構成でセットアップしている場合、以下の追加パッケージが必要です。

* make
* gcc
* gcc-c++
* libicu-devel
* zlib-devel
* which
* sqlite-devel
* gdbm-devel

```bash
cd /path/to/rgrb
bundle install --deployment
```

### 開発時のみ必要なライブラリのインストール

開発時は、メール送信テストを行えるようにするため、[mailcatcher](https://github.com/sj26/mailcatcher) をインストールしてください。

```bash
gem install mailcatcher
```

設定
----

IRC ボット用および Discord ボット用の設定ファイルのテンプレートがそれぞれ同梱されています。
IRC ボット用のテンプレートは [config/irc.yaml](config/irc.yaml) です。
Discord ボット用のテンプレートファイルは [config/discord.yaml](config/discord.yaml) です。
複数の設定を使う場合は、このファイルをコピーして config/ に設置します。

各設定は**設定 ID** によって識別します。設定 ID とは、config/ 以下に設置した YAML ファイルの、config/ を基準とした相対パスから拡張子を除いたものです。例えば config/irc.yaml の場合は `irc` となり、config/trpg/detatoko.yaml の場合は `trpg/detatoko` になります。

プラグインの設定を別のファイルに書くことも可能です。その場合、親となる設定ファイルの `Include` 節で設定 ID を指定し、子となる設定ファイルを取り込みます。ただし、取り込まれたファイルからさらに他の設定ファイルを取り込むことはできません。具体例は上記の設定ファイルのテンプレートでご確認ください。

### プラグイン一覧

#### IRC / Discord 欄の凡例

| 記号 | 意味 |
| ---- | ---- |
| o | 実装済み |
| ! | すべての機能が実装されているわけではない |
| x | 未実装 |
| - | 実装予定なし(チャット環境固有の物) |

#### オンラインセッション支援

| プラグイン名 | 内容 | IRC | Discord |
| ------------ | ---- | --- | ------- |
| [DiceRoll](doc/plugins/dice_roll.md) | ダイスロール | o | o |
| [RandomGenerator](doc/plugins/random_generator.md) | ランダムジェネレータ | o | o |
| [Trpg::Detatoko](doc/plugins/trpg/detatoko.md) | 「でたとこサーガ」専用のダイス・表引きコマンド | o | o |
| [BCDice](doc/plugins/bcdice.md) | [ボーンズ＆カーズ](https://github.com/torgtaitai/BCDice) のダイスコマンドを利用する | o | o |

#### 情報検索・引用

| プラグイン名 | 内容 | IRC | Discord |
| ------------ | ---- | --- | ------- |
| [Keyword](doc/plugins/keyword.md) | キーワード検索 | o | o |
| [OnlineSessionSearch](doc/plugins/online_session_search.md) | [TRPG.NET セッションマッチングシステム](http://session.trpg.net/)から予定されているオンラインセッションの情報を検索する | o | x |
| [CreTwitterCitation](doc/plugins/cre_twitter_citation.md) | Twitter @cre_ne_jp の引用 | o | - |
| [UrlFetchTitle](doc/plugins/url_fetch_title.md) | 発言された URL のページタイトルを取得する | o | - |

#### ユーティリティ

| プラグイン名 | 内容 | IRC | Discord |
| ------------ | ---- | --- | ------- |
| [CreBotHelp](doc/plugins/cre_bot_help.md) | クリエイターズネットワークの IRC ボットとしてのヘルプを表示する | o | o |
| [ServerConnectionReport](doc/plugins/server_connection_report.md) | IRC サーバの接続状態の変化を報告する | o | - |
| [Part](doc/plugins/part.md) | チャンネルからの退出 | o | - |
| [KickBack](doc/plugins/kick_back.md) | RGRB が KICK されたとき、そのチャンネルに再度 JOIN する | o | - |
| [Invite](doc/plugins/invite.md) | RGRB が INVITE されたとき、そのチャンネルに JOIN する | o | - |
| [Jihou](doc/plugins/jihou.md) | 毎日決まった時刻になった時、チャンネルに通知する | o | x |
| [Ctcp](doc/plugins/ctcp.md) | CTCP メッセージを受信した時、適切な応答を返す | o | - |

IRC ボットの起動
----------------

IRC ボットを起動するには、以下を実行してください。Ctrl + C を押すと終了します。

```bash
cd /path/to/rgrb
bin/rgrb-ircbot
```

`-c`（`--config`）オプションで、使用する設定を指定することができます。その場合、`-c` に続けて設定 ID を書きます。

```bash
cd /path/to/rgrb
bin/rgrb-ircbot -c test # /path/to/rgrb/config/test.yaml を使用する場合
```

systemd による制御を行なう場合は [systemd](doc/system/systemd.md) を参照してください。

Discord ボットの招待
--------------------

[招待リンク](https://discordapp.com/api/oauth2/authorize?client_id=590114600650014721&permissions=3072&redirect_uri=https%3A%2F%2Fgithub.com%2Fcre-ne-jp%2Frgrb&scope=bot)

上のリンクをクリックすることで、Discord ボットを、ご自身が管理者になっている Discord サーバに招待することが出来ます。
この場合、ご自身のコンピュータ上で RGRB をインストールしたり、RGRB を起動したりする必要はありません。

Discord ボットの起動
--------------------

(ToDo: 増補)

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
  - http://kataribe.com/cgi/rg.cgi/ のようなもの

連絡先
------

ご意見・ご要望・バグ報告等は、[irc.cre.jp 系 IRC サーバ群](http://www.cre.ne.jp/services/irc)の IRC チャンネル「#cre」や、[GitHub リポジトリ](https://github.com/cre-ne-jp/rgrb)上の「[Issues](https://github.com/cre-ne-jp/rgrb/issues)」・「[Pull Requests](https://github.com/cre-ne-jp/rgrb/pulls)」にて承っております。お気軽にお寄せください。

ライセンス
----------

[MIT License](LICENSE)（[日本語](LICENSE.ja)）

制作
----

&copy; 2014- [クリエイターズネットワーク](http://www.cre.ne.jp/)技術部

* 鯉（[@koi-chan](https://github.com/koi-chan)）
* ocha（[@ochaochaocha3](https://github.com/ochaochaocha3)）
* らぁ（[@raa0121](https://github.com/raa0121)）
* risou（[@risou](https://github.com/risou)）
