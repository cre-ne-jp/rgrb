# vim: fileencoding=utf-8

require 'yaml'

module RGRB
  # RGRB の設定を表すクラス
  class Config
    # IRC ボットの設定のハッシュ
    # @return [Hash]
    attr_reader :irc_bot
    # Redis の設定のハッシュ
    # @return [Hash]
    attr_reader :redis

    # YAML 形式の設定ファイルを読み込み、オブジェクトに変換する
    # @param [String] path YAML 形式の設定ファイルのパス
    # @return [RGRB::Config]
    def self.load_yaml_file(path)
      config_data = YAML.load_file(path)
      irc_bot, redis, plugin_names = %w(IRCBot Redis Plugins).map do |key|
        config_data[key]
      end

      new(irc_bot, redis, plugin_names)
    end

    # 新しい RGRB::Config インスタンスを返す
    # @param [Hash] irc_bot_config IRC ボットの設定のハッシュ
    # @param [Hash] redis_config Redis の設定のハッシュ
    # @param [Array<String>] plugin_names プラグイン名の配列
    # @return [RGRB::Config]
    def initialize(irc_bot_config, redis_config, plugin_names)
      @irc_bot = irc_bot_config
      @redis = redis_config
      @plugins = plugin_names.map do |plugin_name|
        name_snakecase = snakecase(plugin_name)

        require "rgrb/plugin/#{name_snakecase}"
        RGRB::Plugin.const_get(plugin_name)
      end
    end

    # プラグインを表すクラスの配列を返す
    #
    # 複製なので、返された配列を操作しても設定は壊れない
    def plugins
      @plugins.dup
    end

    private

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
  end
end
