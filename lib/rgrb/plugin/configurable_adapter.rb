# vim: fileencoding=utf-8

require 'cinch'

module RGRB
  module Plugin
    # 設定できる生成器のアダプター用のモジュール
    module ConfigurableAdapter
      # 生成器を用意し、設定を転送する
      # @return [true]
      def prepare_generator
        class_name_tree = self.class.name.split('::')
        class_name_tree[-1] = 'Generator'
        generator_class = Object.const_get(class_name_tree.join('::'))
        @generator = generator_class.new

        @generator.root_path = config[:root_path]
        @generator.configure(config[:plugin])

        true
      end
      private :prepare_generator
    end
  end
end
