# vim: fileencoding=utf-8

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
    end

    def initialize(irc_bot, redis, plugin_names)
      @irc_bot = irc_bot
      @redis = redis
      @plugins = plugin_names.map {|plugin_name|
        name_snakecase = snakecase(plugin_name)

        require "rgrb/plugin/#{name_snakecase}"
        RGRB::Plugin.const_get(plugin_name)
      }
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
      return "" if s.empty?

      words_downcase = s.scan(/[A-Z\s]*[^A-Z]*/)[0..-2].map {|word|
        word.gsub(/[\s:]+/, '_').downcase
      }
      words_downcase.join('_').gsub(/__+/, '_')
    end
  end
end
