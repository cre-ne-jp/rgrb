# vim: fileencoding=utf-8

require 'active_support/core_ext/string/inflections'

module RGRB
  module Plugin
    # 設定できる出力テキスト生成器のモジュール
    module ConfigurableGenerator
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
end
