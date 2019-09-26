# frozen_string_literal: true
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
      @plugin_paths = config.plugins.map { |name|
        [name, "#{PLUGINS_ROOT_PATH}/#{name.underscore}"]
      }
    end

    # プラグインの構成要素を require する
    # @param [String, Symbol] component_name
    #   構成要素の名前："Generator" 等
    # @param [boolean] skip_on_load_error
    #   読み込みエラー時に該当要素をスキップするか
    # @return [Array] 読み込んだプラグイン構成要素のクラスの配列
    def load_each(component_name, skip_on_load_error = false)
      loaded_classes = component_paths(component_name).map { |class_name, path|
        try_load(class_name, path, skip_on_load_error)
      }

      loaded_classes.compact
    end

    private

    # プラグインの構成要素のパスの配列を返す
    # @param [String, Symbol] component_name
    #   構成要素の名前："Generator" 等
    # @return [Array<Array<String>>] [クラス名, パス] の配列
    def component_paths(component_name)
      component_name_underscore = component_name.to_s.underscore

      @plugin_paths.map { |name, path|
        ["#{name}::#{component_name}", "#{path}/#{component_name_underscore}"]
      }
    end

    # プラグインの構成要素の読み込みを試みる
    # @param [String] class_name クラス名
    # @param [String] プラグインのパス
    # @param [Boolean] skip_on_load_error
    #   読み込みエラー時に該当要素をスキップするか
    # @return [Class] 正常に読み込めた場合、プラグインのクラスを返す
    # @return [nil] プラグインの読み込みに失敗した場合
    def try_load(class_name, path, skip_on_load_error)
      begin
        require(path)
      rescue LoadError => e
        if skip_on_load_error
          return nil
        else
          raise e
        end
      end

      RGRB::Plugin.const_get(class_name)
    end
  end
end
