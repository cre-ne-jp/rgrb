# vim: fileencoding=utf-8

require 'active_support/core_ext/string/inflections'

module RGRB
  module GeneratorPlugin
    # 設定 ID
    # @return [String]
    attr_accessor :config_id
    # RGRB のルートパス
    # @return [String]
    # @note root_path を設定すると、それに合わせて
    #   data_path も設定される。
    attr_reader :root_path
    # プラグインで使うデータを格納するディレクトリのパス
    # @return [String]
    attr_accessor :data_path
    # ロガー
    # @return [Lumberjack::Logger]
    attr_accessor :logger

    # インスタンスの初期化
    #
    # 設定関連のメソッドが動作するように変数を設定する。
    def initialize
      class_name_tree = self.class.name.split('::')
      @plugin_name_underscore = class_name_tree[-2].underscore
    end

    # RGRB のルートパスを設定する
    # @param [String] root_path RGRB のルートパス
    # @return [String] RGRB のルートパス
    def root_path=(root_path)
      @root_path = root_path
      @data_path = "#{root_path}/data/#{@plugin_name_underscore}"

      root_path
    end

    # 設定データを解釈してプラグインの設定を行う
    #
    # 標準では何も行わない。
    # @return [self]
    def configure(*)
      self
    end
  end
end
