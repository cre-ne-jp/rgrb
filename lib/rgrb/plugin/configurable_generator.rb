# vim: fileencoding=utf-8

require 'active_support/core_ext/string/inflections'

module RGRB
  module Plugin
    # 設定できる出力テキスト生成器のモジュール
    module ConfigurableGenerator
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
        @plugin_script_path = "#{root_path}/lib/rgrb/plugin/#{@plugin_name_underscore}"

        root_path
      end

      # 設定データを解釈してプラグインの設定を行う
      #
      # 標準では何も行わない。
      # @return [self]
      def configure(config_data)
        @dbconfig= config_data['Database'] || ''
        self
      end

      # 使用する DB 名の接頭語を決め、DB 固有のファイルを読み込む
      # @return [Boolean]
      def prepare_database
        options = { 
          dbname_prefix: "rgrb_plugin_#{@plugin_name_underscore}",
          data_path: @data_path,
          config: @dbconfig
        }
        require "#{@plugin_script_path}/db_#{@dbconfig['Type']}"

        class_name_tree = self.class.name.split('::')
        class_name_tree[-1] = 'Database'
        database_class = Object.const_get(class_name_tree.join('::'))
        @db = database_class.new(options)
      end
    end
  end
end
