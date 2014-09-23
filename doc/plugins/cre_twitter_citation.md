CreTwitterCitation
==================

Twitter @cre_ne_jp の発言を引用するためのプラグインです。

一定間隔で @cre_ne_jp の発言をチェックし、新しいツイートの内容を NOTICE します。

使用には [Twitter Apps](https://apps.twitter.com/) としての登録が必要です。

設定
----

設定ファイルに以下を追加して、プラグインの設定を行います。

```yaml
# Twitter @cre_ne_jp 引用プラグインの設定
CreTwitterCitation:
  # タイムライン監視の間隔（秒）
  # あまり短いとアクセス規制になるので注意
  # 60 以上を推奨
  CheckInterval: 300

  # チェックごとに取得するツイートの最大数
  MaxTweetsPerCheck: 3

  # NOTICE を行うチャンネルの一覧
  ChannelsToSend:
    - '#cre'

  # Twitter アカウント関連
  Twitter:
    # Twitter ID（@〜）
    ID: cre_ne_jp

    # API キー関連
    # https://apps.twitter.com/ で確認可能
    APIKey: ''
    APISecret: ''
    AccessToken: ''
    AccessTokenSecret: ''
```
