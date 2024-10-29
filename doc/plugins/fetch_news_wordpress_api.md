FetchNewsWordpressApi
=====================

一定間隔で [クリエイターズネットワーク公式サイト](https://www.cre.ne.jp/) に新しく投稿された告知記事があるかチェックし、新規記事のタイトルと URL を NOTICE します。


設定
----

設定ファイルに以下を追加して、プラグインの設定を行います。

```yaml
# 公式WP (https://www.cre.ne.jp/) 記事引用プラグインの設定
FetchNewsWordpressApi:
  # 新規投稿を監視する間隔（秒）
  # あまり短いとアクセス規制になるので注意
  # 60 以上を推奨
  CheckInterval: 300

  # チェックごとに取得する記事の最大数
  MaxPostsPerCheck: 3

  # NOTICE を行うチャンネルの一覧
  ChannelsToSend:
    - '#cre'
```
