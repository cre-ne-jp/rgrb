UrlFetchTitle
=============

発言（PRIVMSG）に URL が含まれている場合、そこからタイトルを取得します。

実装は [Tiarra](http://www.clovery.jp/tiarra/) の [Auto::FetchTitle](https://bitbucket.org/mapi/tiarra/src/8c21fe9d660e4f4c85c408c95e3ab379d20c22aa/module/Auto/FetchTitle.pm?at=default&fileviewer=file-view-default) や [Mechanize](https://github.com/sparklemotion/mechanize) の [Mechanize::Page](https://github.com/sparklemotion/mechanize/blob/master/lib/mechanize/page.rb) を参考にしています。

コマンド
--------

コマンドはありません。発言時に自動的に動作します。

タイトル取得の条件
------------------

タイトルの取得は、以下のすべてを満たした場合に行われます。

1. HTTP または HTTPS スキームの URL の場合。
2. HTTP レスポンスの Content-Type ヘッダが text/html または application/xhtml+xml の場合。

タイトル取得の手順
------------------

上記の条件を満たした場合、次に HTML ファイルの先頭を読み込みます。読み込みはファイルの最後に達するか、設定 `ReadSizeThreshold` 以上のバイト数を読み込んだときに停止します。

続いてエンコーディングの判別を行います。エンコーディングの候補は、以下の優先順位で追加されます。

1. HTML の meta タグで指定された charset の値。
2. HTTP レスポンスの Content-Type ヘッダで指定された charset の値。
3. HTML ファイルの内容から判定されたエンコーディングの候補。

これらのエンコーディングの候補について、優先順位の高いものから順に、そのエンコーディングと見做した場合に無効な文字が含まれていないかを調べます。無効な文字が含まれていない場合、そのエンコーディングが確定されます。

最後に、確定されたエンコーディングで HTML コードを解析し、title タグの内容を抜き出します。

設定
----

設定ファイルに以下を追加して、プラグインの設定を行います。

```yaml
# UrlFetchTitle プラグインの設定
UrlFetchTitle:
  # 書き込みタイムアウト
  WriteTimeout: 2
  # 接続タイムアウト
  ConnectTimeout: 5
  # 読み込みタイムアウト
  ReadTimeout: 5
  # 最大リダイレクト回数
  MaxRedirects: 5
  # 読み込みサイズ閾値（バイト単位）
  ReadSizeThreshold: 65536
  # 返信の接頭辞
  ReplyPrefix: 'FetchTitle: '
  # 返信の接尾辞
  ReplySuffix: ''

  # HTTP 接続用の User-Agent
  # %s を書くと、RGRBのバージョンに置換される
  UserAgent: "RGRB/%s (Creator's Network IRC bot)"
```
