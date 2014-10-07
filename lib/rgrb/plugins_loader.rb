# vim: fileencoding=utf-8

require 'active_support/core_ext/string/inflections'

module RGRB
  # プラグインおよびそのアダプターの require を担うクラス
  class PluginsLoader
    # プラグインのルートディレクトリ
    PLUGINS_ROOT_PATH = 'rgrb/plugin'

    # 新しい PluginsLoader インスタンスを返す
    # @param [Config] config RGRB の設定
    # @return [PluginsLoader]
    def initialize(config)
      @plugin_names = config.plugins
      @plugin_path = Hash[
        @plugin_names.map do |name|
          [name, "#{PLUGINS_ROOT_PATH}/#{name.underscore}"]
        end
      ]
    end

    # プラグインの構成要素を require する
    # @param [String] component_name 構成要素の名前："Generator" 等
    # @param [boolean] skip_on_load_error
    #   読み込みエラー時に該当要素をスキップするか
    # @return [Array] 読み込んだプラグイン構成要素のクラスの配列
    def load_each(component_name, skip_on_load_error = false)
      component_name_underscore = component_name.underscore
      component_path = Hash[
        @plugin_path.map do |name, path|
          [
            "#{name}::#{component_name}",
            "#{path}/#{component_name_underscore}"
          ]
        end
      ]

      loaded_class = component_path.map do |class_name, path|
        if skip_on_load_error
          begin
            require path
          rescue LoadError
            next nil
          end
        else
          require path
        end

        if RGRB::Plugin.const_defined?(class_name)
          RGRB::Plugin.const_get(class_name)
        else
          nil
        end
      end

      loaded_class.compact
    end
  end
end
