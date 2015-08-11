ServerConnectionReport
======================

IRC サーバの接続状態の変化を報告するプラグインです。お使いの IRC デーモンに合わせて有効化するものを選択してください。

設定
----

設定ファイルのプラグインリストに、以下のいずれかを追加します。

```yaml
Plugins:
  - ServerConnectionReport::Ngircd
  - ServerConnectionReport::Charybdis
  - ServerConnectionReport::AthemeServices
```

以下で説明する、サーバの接続状態を報告するチャンネル（設定項目 `ChannelsToSend` で設定します）に JOIN しておかなければ、IRC サーバに発言が拒否されてプラグインが動作しないことがあります。


```yaml
IRCBot:
  #### 省略 ####
  # JOIN するチャンネルの一覧
  Channels:
    - '#cre'
```

報告先チャンネルのモードに +n（チャンネルに入っていないクライアントからの発言を拒否する）を設定しないことでも動作可能となりますが、スパムメッセージを許すことにつながりかねないため、推奨されません。

IRC デーモンごとの動作・設定
----------------------------

### ngIRCd

接続先の「&SERVER」チャンネルに書き込まれるメッセージを監視して IRC サーバの接続状態の変化を検知しています。

設定ファイルに以下を追加して、プラグインの設定を行います。

```yaml
# サーバーリレー監視プラグインの設定
ServerConnectionReport::Ngircd:
  # NOTICE を行なうチャンネルの一覧
  ChannelsToSend:
    - '#cre'
```

### Charybdis

charybdis は、初期設定では IRC サーバーオペレータ権（Oper）を持っている人に、サーバーメッセージで接続・切断などのステータスを送信するようになっています。このサーバーメッセージを検知します。

設定ファイルに以下を追加して、プラグインの設定を行います。

```yaml
# Charybdis 用サーバーリレー監視プラグインの設定
ServerConnectionReport::Charybdis:
  # NOTICE を行うチャンネルの一覧
  ChannelsToSend:
    - '#cre'
```

### Atheme-Services

Atheme-Services を利用している環境であれば、IRC デーモンの種類を問わずこのプラグインでサーバーの接続状態を検知できます。初期設定では「#services」チャンネルに情報が出力されます。RGRB がこのチャンネルに参加している必要があります。

設定ファイルに以下を追加して、プラグインの設定を行います。

```yaml
# Atheme-Services 用サーバーリレー監視プラグインの設定
ServerConnectionReport::AthemeServices:
  # NOTICE を行うチャンネルの一覧
  ChannelsToSend:
    - '#cre'
```
