# vim: fileencoding=utf-8

module RGRB
  module PluginBase
    # アダプターの共通モジュール
    module Adapter
      # 生成器を用意し、設定を転送する
      # @return [true]
      def prepare_generator
        class_name_tree = self.class.name.split('::')
        class_name_tree[-1] = 'Generator'
        generator_class = Object.const_get(class_name_tree.join('::'))
        @generator = generator_class.new

        @generator.config_id = config.id
        @generator.root_path = config.root_path

        # TODO: プラグインでのテキスト生成関連のログを専用のロガーで出力できる
        # ようにする
        #
        # 現在はアダプタ自体をロガーとして使う
        @generator.logger = self

        @generator.configure(config.plugin)

        true
      end
      private :prepare_generator
    end
  end
end
