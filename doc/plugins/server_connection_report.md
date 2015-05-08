ServerConnectionReport
======================

IRC サーバの接続状態の変化を報告するプラグインです。
お使いのIRCデーモンに合わせて有効化するものを選択してください。

設定
----

設定ファイルのプラグインリストに、以下を追加します。

```yaml
Plugins:
  - ServerConnectionReport::NgIRCd
  - ServerConnectionReport::Charybdis
  - ServerConnectionReport::AthemeServices
```

ngIRCd
------
接続先の「&SERVER」チャンネルに書き込まれるメッセージを監視して IRC サーバの接続状態の変化を検知しています。

設定ファイルに以下を追加して、プラグインの設定を行います。

```yaml
# サーバーリレー監視プラグインの設定
ServerConnectionReport::NgIRCd
  # NOTICE を行なうチャンネルの一覧
  ChannelsToSend:
    - '#cre'
```

Charybdis
---------

charybdis は、初期設定ではIRCサーバーオペレータ権(Oper)を持っている人に、サーバーメッセージで接続・切断などのステータスを送信するようになっています。
このサーバーメッセージを検知します。

設定ファイルに以下を追加して、プラグインの設定を行います。

```yaml
# Charybdis 用サーバーリレー監視プラグインの設定
ServerConnectionReport::Charybdis:
  # NOTICE を行うチャンネルの一覧
  ChannelsToSend:
    - ''
```

Atheme-Services
---------------

Atheme-Services を利用している環境であれば、IRCデーモンの種類を問わず子のプラグインでサーバーの接続状態を検知できます。
初期設定では #services チャンネルに情報が出力されます。RGRB がこのチャンネルに参加している必要があります。

設定ファイルに以下を追加して、プラグインの設定を行います。

```yaml
# Atheme-Services 用サーバーリレー監視プラグインの設定
ServerConnectionReport::AthemeServices:
  # NOTICE を行うチャンネルの一覧
  ChannelsToSend:
    - ''
```
