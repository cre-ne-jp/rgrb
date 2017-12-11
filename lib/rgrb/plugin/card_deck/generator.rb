# vim: fileencoding=utf-8

require 'rgrb/plugin/configurable_generator'
require 'rgrb/plugin/use_logger'
require 'rgrb/plugin/card_deck/channel_data'

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
          set_logger(config_data)

          @channel_data = ChannelDatas.new(
            @data_path,
            @logger
          )

          self
        end

        # デッキをチャンネルで使えるようにする
        # @param [String] channel チャンネル名
        # @param [String] deck デッキ名
        # @return [String]
        def deck_initialize(channel, deck)
          "デッキ #{deck} を初期化しました。残り #{@channel_data.deck_initialize(channel, deck)} 枚です"
        rescue => e
          mes = "#{channel} にて #{deck} の初期化に失敗しました"
          @logger.error(mes)
          @logger.error(e)
          mes
        end

        # デッキを破棄する
        # @param [String] channel チャンネル名
        # @param [String] deck デッキ名
        # @return [String]
        def deck_destroy(channel, deck)
          return "デッキ #{deck} は存在しません" unless @channel_data.deck_exist?(deck)

          begin
            @channel_data.deck_destroy(channel, deck)
            "デッキ #{deck} を破棄しました"
          rescue => e
            "デッキ #{deck} は #{channel} で初期化されていません"
          end
        end

        # デッキからカードを引く
        # @param [String] channel チャンネル名
        # @param [String] deck デッキ名
        # @return [String]
        def card_draw(channel, deck)
          return "デッキ #{deck} は存在しません" unless @channel_data.deck_exist?(deck)

          begin
            @channel_data.card_draw(channel, deck)
          rescue => e
            "デッキ #{deck} は #{channel} で初期化されていません"
          end
        end

        # デッキの残り枚数を返す
        # @param [String] channel チャンネル名
        # @param [String] deck デッキ名
        # @return [String]
        def card_count(channel, deck)
          "#{channel} での #{deck} の残り枚数は #{@channel_data.card_count(channel, deck)} 枚です"
        rescue => e
          "デッキ #{deck} は #{channel} で初期化されていません"
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
