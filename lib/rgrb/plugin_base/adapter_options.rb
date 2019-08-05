# vim: fileencoding=utf-8

module RGRB
  module PluginBase
    # アダプタに渡される設定などを含む構造体
    AdapterOptions = Struct.new(
      # 設定 ID
      :id,
      # RGRB のルートディレクトリのパス
      :root_path,
      # プラグインの設定
      :plugin,
      # 将来のロガー設定用のメンバ
      #
      # TODO: プラグインでのテキスト生成関連のログをこのロガーで出力できる
      # ようにする
      :logger,
    )
  end
end
