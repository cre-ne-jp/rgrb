# vim: fileencoding=utf-8

module RGRB
  module PluginBase
    # アダプターの共通モジュール
    module Adapter
      private

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
        # 注意：アダプタは必ずジェネレータ用のロガーを返す logger_for_generator
        # メソッドを必ず定義すること。
        @generator.logger = logger_for_generator

        @generator.configure(config.plugin)

        true
      end
    end
  end
end
