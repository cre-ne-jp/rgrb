汎用ダイスボット「RGRB」
========================

RGRBとは
--------
IRC、CGIなどの複数のモードで動作する汎用ダイスボットです。Rubyで実装されています。

プラグイン方式により柔軟な拡張を可能とすることを目標としています。

インストール
------------
1. 適切なディレクトリにファイルを設置してください。
2. [Bundler](http://bundler.io/) をインストールしていない場合は以下を実行してください。

    ```bash
    gem install bundler
    ```
3. 以下を実行して必要な gem（ライブラリ）をインストールしてください。

    ```bash
    cd /path/to/rgrb
    bundle install --path=vendor/bundler
    ```
