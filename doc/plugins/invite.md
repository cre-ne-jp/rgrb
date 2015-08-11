Invite
======

RGRB が INVITE (招待)されたとき、そのチャンネルに JOIN するプラグインです。JOIN 時に特定のメッセージを発言することができます。

コマンド
--------

コマンドはありません。INVITE されたとき、自動的に動作します。

設定
----

設定ファイルに以下を追加して、プラグインの設定を行います。

```yaml
# Invite プラグインの設定
Invite:
  # INVITE された時、JOIN 時に発言するメッセージ
  JoinMessage: 
    - "ご招待いただきありがとう☆"
```

JoinMessage は、発言1行を1つの要素として、配列形式で記述してください。