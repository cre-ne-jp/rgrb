# vim: fileencoding=utf-8

module RGRB
  module PluginBase
    # アダプターの共通モジュール
    module Adapter
      def initialize(*)
        super

        @config_id = config.id
        @root_path = config.root_path
        @plugin_config = config.plugin
        @logger = config.logger
      end

      # 生成器を用意し、設定を転送する
      # @return [true]
      def prepare_generator
        class_name_tree = self.class.name.split('::')
        class_name_tree[-1] = 'Generator'
        generator_class = Object.const_get(class_name_tree.join('::'))
        @generator = generator_class.new

        @generator.config_id = config.id
        @generator.root_path = config.root_path
        @generator.logger = config.logger

        # プラグインをロガーとして使えるよう、設定に含める
        config_data = config.plugin.merge({ logger: self })
        @generator.configure(config_data)

        true
      end
      private :prepare_generator
    end
  end
end
