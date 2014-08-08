DiceRoll
========

ダイスロールを行えるようにするプラグインです。

コマンド
--------

### ダイスロール (`.roll fdp`, `.roll fDp`)

面数 _p_ のダイスを _f_ 個振ったときの合計値を返します。

#### 例

```
.roll 2d6
> foo -> 2d6 = [6, 2] = 8

.roll 1D6
> foo -> 1d6 = [1] = 1
```

ToDo
----

* 「[ボーンズ＆カーズ](https://github.com/torgtaitai/BCDice)」 並みにダイスロールの種類を増やす？
