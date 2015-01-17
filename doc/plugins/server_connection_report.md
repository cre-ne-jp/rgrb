ServerConnectionReport
======================

IRC サーバの接続状態の変化を報告するプラグインです。

接続先の「&SERVER」チャンネルに書き込まれるメッセージを監視して IRC サーバの接続状態の変化を検知しています。

設定
----

設定ファイルに以下を追加して、プラグインの設定を行います。

```yaml
# サーバーリレー監視プラグインの設定
ServerConnectionReport:
  # NOTICE を行なうチャンネルの一覧
  ChannelsToSend:
    - '#cre'
```
