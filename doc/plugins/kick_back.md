KickBack
========

RGRB が KICK されたとき、そのチャンネルに再度 JOIN するプラグインです。再 JOIN 時に特定のメッセージを発言することができます。

コマンド
--------

コマンドはありません。KICK されたとき、自動的に動作します。

設定
----

設定ファイルに以下を追加して、プラグインの設定を行います。

```yaml
# KickBack プラグインの設定
KickBack:
  # KICK された後、再 JOIN 時に発言するメッセージ
  JoinMessage: '退出させるときは .part を使ってね☆'
```
