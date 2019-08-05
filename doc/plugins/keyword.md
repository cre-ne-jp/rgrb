Keyword
=======

キーワード検索を行えるようにするプラグインです。

コマンド
--------

### cre.jp 検索

#### 書式

```
.k <キーワード>
```

#### 説明

[cre.jp 検索ページ](http://cre.jp/search/)の検索結果の URL を返します。

#### 例

```
.k SW 2.0
> キーワード一覧の http://cre.jp/search/?sw=SW+2.0 をどうぞ♪
```

### Amazon.co.jp 検索

#### 書式

```
.a <キーワード>
```

#### 説明

[Amazon.co.jp](http://www.amazon.co.jp/) の検索結果の URL を返します。

#### 例

```
.a SW 2.0
> Amazon.co.jp の商品一覧から http://www.amazon.co.jp/gp/search?ie=UTF8&tag=koubou-22&keywords=SW+2.0 をどうぞ♪
```

設定
----

設定ファイルに以下を追加して、プラグインの設定を行います。

```yaml
# キーワード検索プラグインの設定
Keyword:
  # Amazon 検索で使用するアソシエイト ID
  AmazonAssociateID: koubou-22
```
