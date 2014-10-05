# vim: fileencoding=utf-8

require 'yaml'

module RGRB
  # RGRB の設定を表すクラス
  class Config
    # IRC ボットの設定のハッシュ
    # @return [Hash]
    attr_reader :irc_bot
    # プラグイン名の配列
    # @return [Array<String>]
    attr_reader :plugins
    # プラグイン設定のハッシュ
    # @return [Hash]
    attr_reader :plugin_config

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
      @plugins = config_data['Plugins'] || []
      @plugin_config = Hash[
        @plugins.map { |name| [name, config_data[name]] }
      ]
    end
  end
end
