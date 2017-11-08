# vim: fileencoding=utf-8

require 'sdbm'

require 'rgrb/plugin/configurable_generator'
require 'rgrb/plugin/use_logger'
require 'rgrb/plugin/card_deck/deck'

module RGRB
  module Plugin
    # カードデッキプラグイン
    module CardDeck
      # CardDeck の出力テキスト生成器。
      class Generator
        include ConfigurableGenerator
        include UseLogger

        def initialize
          super

          prepare_default_logger
        end

        # 設定データを解釈してプラグインの設定を行う
        # @param [Hash] config_data プラグインの設定データ
        # @return [self]
        def configure(config_data)
          # チャンネルデータベースを読み出す
          #@channel_data = SDBM.open("#{@data_path}/channel")
          @channel_data = {}
          # デッキが保存されているディレクトリのパス
          @deck_path = "#{@data_path}/decks/"

          load_decks("#{@data_path}/decks/*.yaml")

          set_logger(config_data)

          self
        end

        # デッキをチャンネルで使えるようにする
        # @param [String] channel チャンネル名
        # @param [String] deck デッキ名
        # @return [String]
        def deck_initialize(channel, deck)
          return "デッキ #{deck} は存在しません" if @decks[deck] == nil
          if @channel_data[channel] == nil
            @channel_data[channel] = {}
          elsif initialized?(channel, deck)
            return "既に #{channel} で #{deck} は初期化済みです"
          end

          @channel_data[channel][deck] =
            Array.new(@decks[deck].values.size) { |index| index }.shuffle

          "デッキ #{deck} を初期化しました。残り #{@channel_data[channel][deck].size} 枚です"
        end

        # デッキからカードを引く
        # @param [String] channel チャンネル名
        # @param [String] deck デッキ名
        # @return [void]
        def card_draw(channel, deck)
          return "デッキ #{deck} は存在しません" if @decks[deck] == nil
          return "#{channel} でデッキ #{deck} は未初期化です" if initialized?(channel, deck)

          id = @channel_data[channel][deck].pop
          if id == nil
            "デッキ #{deck} は空です"
          else
            "結果: #{@decks[deck].values[id]} / 残り: #{@channel_data[channel][deck].size} 枚です"
          end
        end

        # デッキの情報を出力する
        # @param [String] deck_name デッキ名
        # @return [void]
        def deck_info(deck_name)
        end

        # ヘルプを表示する
        # @return [void]
        def help
        end

        private

        # デッキをデータベースから読み込む
        # @param [String] glob_pattern デッキファイル名のパターン
        # @return [void]
        def load_decks(glob_pattern)
          @decks = {}

          Dir.glob(glob_pattern).each do |path|
            begin
              yaml = File.read(path, encoding: 'UTF-8')
              deck = Deck.parse_yaml(yaml)

              @decks[deck.name] = deck
            rescue => e
              logger.error("データファイル #{path} の読み込みに失敗しました")
              logger.error(e)
            end
          end
        end

        # チャンネルでデッキが初期化されているか
        # @param [String] channel チャンネル名
        # @param [String] deck デッキ名
        # @return [Boolean]
        def initialized?(channel, deck)
          @channel_data[channel][deck].class == 'array'
        end

        # 日付の日本語表記を返す
        # @param [Date, DateTime] date 日付
        # @return [String]
        def japanese_date(date)
          "#{date.year}年#{date.month}月#{date.day}日"
        end
      end
    end
  end
end
