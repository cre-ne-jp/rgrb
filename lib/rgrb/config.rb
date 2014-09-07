# vim: fileencoding=utf-8

require 'yaml'

module RGRB
  # RGRB の設定を表すクラス
  class Config
    # IRC ボットの設定のハッシュ
    # @return [Hash]
    attr_reader :irc_bot

    # YAML 形式の設定ファイルを読み込み、オブジェクトに変換する
    # @param [String] path YAML 形式の設定ファイルのパス
    # @return [RGRB::Config]
    def self.load_yaml_file(path)
      new(YAML.load_file(path))
    end

    # 新しい RGRB::Config インスタンスを返す
    # @param [Hash] config_data 設定データのハッシュ
    # @return [RGRB::Config]
    def initialize(config_data)
      @irc_bot = config_data['IRCBot']
      @plugins = config_data['Plugins'].map do |plugin_name|
        require "rgrb/plugin/#{snakecase(plugin_name)}"
        RGRB::Plugin.const_get(plugin_name)
      end

      @plugin_config = Hash[
        @plugins.map do |plugin_class|
          [
            plugin_class,
            config_data[plugin_class.name.split('::').last]
          ]
        end
      ]
    end

    # プラグインを表すクラスの配列を返す
    #
    # 複製なので、返された配列を操作しても設定は壊れない
    #
    # @return [Array]
    def plugins
      @plugins.dup
    end

    # プラグインの設定データを返す
    # @return [Hash]
    def plugin_config(plugin_class)
      @plugin_config[plugin_class]
    end

    # アンダースコアでつないだ単語を返す
    # @param [String] s 変換する文字列
    # @return [String]
    def snakecase(s)
      return '' if s.empty?

      words_downcase = s.scan(/[A-Z\s]*[^A-Z]*/)[0..-2].map do |word|
        word.gsub(/[\s:]+/, '_').downcase
      end
      words_downcase.join('_').gsub(/__+/, '_')
    end
    private :snakecase
  end
end
