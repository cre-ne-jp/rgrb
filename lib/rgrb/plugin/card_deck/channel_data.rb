require 'json'
require 'rgrb/plugin/card_deck/deck'

module RGRB
  module Plugin
    module CardDeck
      # チャンネル別のデッキデータを表すクラス
      #
      # JSON データベースへの読み書きや、デッキの使用を管理する
      class ChannelDatas
        # 使用可能なデッキ名
        # @return [Array]
        attr_reader :decks_list

        # チャンネルデータを用意する
        # @param [String] data_path データパス
        # @param [Logger] logger ログ出力
        # @return [ChannelDatas]
        def initialize(data_path, logger)
          @logger = logger

          # チャンネルデータファイルへのパス
          @json_path = "#{data_path}/channel.json"

          load_decks("#{data_path}/decks/*.yaml")
          load_json
        end

        # デッキが存在するか
        # @param [String] deck
        # @return [Boolean]
        def deck_exist?(deck)
          @decks_list.include?(deck)
        end

        # チャンネルを初期化する
        # @param [String] channel
        # @return [Boolean]
        def channel_initialize(channel)
          @channel_data[channel] = {}
        end

        # チャンネルにデッキを用意する
        # @param [String] channel チャンネル名
        # @param [String] deck デッキ名
        # @return [Integer] カード枚数
        def deck_initialize(channel, deck)
          unless deck_exist?(deck)
            raise(StandardError, "Deck '#{deck}' is not found")
          end

          channel_initialize(channel) unless channel_initialized?(channel)

          if deck_initialized?(channel, deck)
            raise(StandardError, "Deck '#{deck}'@#{channel} is already initialized")
          end

          @channel_data[channel][deck] =
            Array.new(@decks[deck].size) { |index| index }.shuffle
          save_json

          card_count(channel, deck)
        end

        # デッキの残り枚数を返す
        # @param [String] channel チャンネル名
        # @param [String] deck デッキ名
        # @return [String]
        def card_count(channel, deck)
          @channel_data[channel][deck].size
        end

        # デッキを破棄する
        # @param [String] channel チャンネル名
        # @param [String] deck デッキ名
        # @return [String]
        def deck_destroy(channel, deck)
          unless channel_initialized?(channel)
            raise(StandardError, "Channel '#{channel}' is not initialized")
          end

          unless deck_initialized?(channel, deck)
            raise(StandardError, "Deck '#{deck}'@#{channel} is not initialized")
          end

          @channel_data[channel].delete(deck)
          save_json
        end

        # デッキからカードを引く
        # @param [String] channel
        # @param [String] deck
        # @return [String]
        def card_draw(channel, deck)
          unless channel_initialized?(channel)
            raise(StandardError, "Channel '#{channel}' is not initialized")
          end

          unless deck_initialized?(channel, deck)
            raise(StandardError, "Deck '#{deck}'@#{channel} is not initialized")
          end

          id = @channel_data[channel][deck].pop

          if id.nil?
            "デッキ #{deck} は空です"
          else
            save_json
            "結果: #{@decks[deck].values[id]} / 残り: #{@channel_data[channel][deck].size} 枚です"
          end
        end

        # デッキに残ったカードの枚数を数える
        # @param [String] channel
        # @param [String] deck
        # @return [Integer]
        def card_count(channel, deck)
          unless channel_initialized?(channel)
            raise(StandardError, "Channel '#{channel}' is not initialized")
          end

          unless deck_initialized?(channel, deck)
            raise(StandardError, "Deck '#{deck}'@#{channel} is not initialized")
          end

          @channel_data[channel][deck].size
        end

        private

        # チャンネルが初期化されているか
        # @param [String] channel チャンネル名
        # @return [Boolean]
        def channel_initialized?(channel)
          @channel_data.keys.include?(channel)
        end

        # チャンネルでデッキが初期化されているか
        # @param [String] channel チャンネル名
        # @param [String] deck デッキ名
        # @return [Boolean]
        def deck_initialized?(channel, deck)
          @channel_data[channel][deck].class == Array
        end

        # デッキをデータベースから読み込む
        # @param [String] glob_pattern デッキファイル名のパターン
        # @return [Hash]
        def load_decks(glob_pattern)
          @decks = {}
          @decks_list = []

          Dir.glob(glob_pattern).each do |path|
            begin
              yaml = File.read(path, encoding: 'UTF-8')
              deck = Deck.parse_yaml(yaml)

              @decks[deck.name] = deck
              @decks_list << deck.name
            rescue => e
              logger.error("データファイル #{path} の読み込みに失敗しました")
              logger.error(e)
            end
          end
        end

        # チャンネルデータを JSON ファイルから読み込む
        # @return [void]
        def load_json
          begin
            @channel_data = File.open(@json_path) do |file|
              JSON.parse(file.read)
            end
          rescue Errno::ENOENT => e
            @logger.warn("チャンネルデータ #{@json_path} を新規作成します")
            @channel_data = {}
            save_json
          rescue => e
            @logger.error("チャンネルデータ #{@json_path} の読み込みに失敗しました")
            @logger.error(e)
          end
          @logger.warn("チャンネルデータ #{@json_path} の読み込みが完了しました")
        end

        # チャンネルデータを JSON ファイルに保存する
        # @return [void]
        def save_json
          begin
            File.open(@json_path, 'w') do |file|
              JSON.dump(@channel_data, file)
            end
          rescue => e
            @logger.error("チャンネルデータ #{@json_path} の保存に失敗しました")
            @logger.error(e)
          end
          @logger.warn("チャンネルデータ #{@json_path} の保存が完了しました")
        end
      end
    end
  end
end
