RandomGenerator
===============

ランダムジェネレータのプラグインです。決定表からランダムに引いた結果を見ることができます。

コマンド
--------

### ランダムジェネレート (`.rg table`)

決定表 _table_ からランダムに引いた結果を返します。

決定表の一覧は以下を参照してください。

* [ロールの ランダムジェネレータ](http://kataribe.com/cgi/rg.cgi/)
* [TRPG.NET Wiki - RoleBot#決定表](http://hiki.trpg.net/wiki/?RoleBot#l19)

#### 例

```
.rg place
> rg[foo]<place>: 夜の町角 ですわ☆

.rg SVOC
> rg[foo]<SVOC>: スケスケの、タコが、妖怪と、ダベってる。 ですわ☆
```

#### エラー

##### rg[foo]: 「_table_」なんて表は見つからないのですわっ。

決定表が見つからない場合に返ります。

### 決定表の説明 (`.rg-desc table`)

決定表 _table_ の説明を返します。

#### 例

```
.rg-desc birthday
> rg-desc<birthday>: 誕生日を選びます。4年に1回の閏年にのみ対応しています(ユリウス暦)。

.rg-desc 6you
> rg-desc<6you>: 六曜から一つを選びます。
```

#### エラー

#####  rg-desc: 「_table_」なんて表は見つからないのですわっ。

決定表が見つからない場合に返ります。

### 決定表の情報 (`.rg-info _table_`)

決定表 _table_ について、以下の4点を調べて返します。

* 作成者
* 追加日
* 最終更新日
* 説明

#### 例

```
.rg-info CharacterFunction
> rg-info<CharacterFunction>: 「CharacterFunction」の作者は koi-chan さんで、2014年12月22日 に追加されましたの。最後に更新されたのは 2014年12月22日 ですわ。『昔話の形態学』より、「行動領域」から1つ選びます。

.rg-info kanji-s1
> rg-info<kanji-s1>: 「kanji-s1」の作者は koi-chan さんで、2014年12月15日 に追加されましたの。最後に更新されたのは 2014年12月20日 ですわ。小学1年生で習う漢字80字の中から一つを選びます。
```

#### エラー

##### rg-info: 「_table_」なんて表は見つからないのですわっ。

決定表が見つからない場合に返ります。
