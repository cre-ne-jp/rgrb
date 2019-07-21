# vim: fileencoding=utf-8

require 'yaml'

module RGRB
  # RGRB の設定を表すクラス
  class Config
    # 設定 ID
    # @return [String]
    attr_reader :id
    # IRC ボットの設定のハッシュ
    # @return [Hash]
    attr_reader :irc_bot
    # Discord ボットの設定のハッシュ
    # @return [Hash]
    attr_reader :discord_bot
    # プラグイン名の配列
    # @return [Array<String>]
    attr_reader :plugins
    # プラグイン設定のハッシュ
    # @return [Hash]
    attr_reader :plugin_config

    class << self
      # 設定 ID から設定ファイルのパスに変換する
      # @param [String] config_id 設定 ID
      # @param [String] root_path 設定ファイルのルートディレクトリのパス
      def config_id_to_path(config_id, root_path)
        if config_id.include?('../')
          fail(ArgumentError, "#{config_id}: ディレクトリトラバーサルの疑い")
        end

        "#{root_path}/#{config_id}.yaml"
      end

      # YAML 形式の設定ファイルを読み込み、オブジェクトに変換する
      # @param [String] config_id 設定 ID
      # @param [String] root_path 設定ファイルのルートディレクトリのパス
      # @return [RGRB::Config]
      def load_yaml_file(config_id, root_path)
        config_path = config_id_to_path(config_id, root_path)
        config_data = YAML.load_file(config_path)

        ids_to_include = config_data['Include'].dup || []
        ids_to_include.each do |id|
          child_config_path = config_id_to_path(id, root_path)
          child_config_data = YAML.load_file(child_config_path)
          config_data.merge!(child_config_data)
        end

        new(config_id, config_data)
      end
    end

    # 新しい RGRB::Config インスタンスを返す
    # @param [String] id 設定 ID
    # @param [Hash] config_data 設定データのハッシュ
    # @return [RGRB::Config]
    def initialize(id, config_data)
      @id = id
      @irc_bot = config_data['IRCBot']
      @discord_bot = config_data['DiscordBot']
      @plugins = config_data['Plugins'] || []
      @plugin_config = {}

      @plugins.each do |name|
        @plugin_config[name] = config_data[name]
      end
    end
  end
end
