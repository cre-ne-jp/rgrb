Ctcp
========

RGRB に CTCP メッセージが送信されたとき、適切な応答を返します。

コマンド
--------

CTCP コマンドを送信します。

対応している CTCP メッセージは、以下の通りです。

* CLIENTINFO
* PING
* SOURCE
* TIME
* USERINFO
* VERSION

設定
----

設定ファイルに以下を追加して、プラグインの設定を行います。

```yaml
# CTCP 応答プラグインの設定
Ctcp:
  # USERINFO のメッセージ
  UserInfo: 'RGRB 稼働中'
```
