Part
====

コマンドを発言されたとき、そのチャンネルから退出するプラグインです。

コマンド
--------

### チャンネルからの退出（`.part` / `.part-NICK`）

どちらのコマンドもチャンネルから退出するという機能に違いはありません。そのチャンネルに複数の `.part` コマンドに反応するボットがいた時に、ニックネームを指定して退出させるために、後者のコマンドも用意されています。

_NICK_ には、退出させたいボットのニックネームを入れます。アルファベットの大文字・小文字の違いは無視します。

#### 例

```
.part
.part-rgrb (ニックネームが "rgrb" の場合)
```

設定
----

設定ファイルに以下を追加して、プラグインの設定を行います。

```yaml
# 退出プラグインの設定
Part:
  # 退出時のメッセージ
  # (IRCプロトコルにおける) PART コマンドの引数として使われます。
  PartMessage: 'ご利用ありがとうございました'
```