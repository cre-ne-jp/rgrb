# vim: fileencoding=utf-8

require 'sdbm'

require 'rgrb/plugin/configurable_generator'
require 'rgrb/plugin/use_logger'

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
          @channel_data = SDBM.open("#{@data_path}/channel")
          # デッキが保存されているディレクトリのパス
          @deck_path = "#{@data_path}/decks/"

          load_decks

          set_logger(config_data)

          self
        end

        # デッキをデータベースから読み込む
        # @return [void]
        def load_decks
          deck_list = []
          Dir.glob("#{@deck_path}/*.dir").each do |file|
            path = "#{@deck_path}/#{file}"
            deck_list << path if File.exist?("#{path}.pag")
          end

          @decks = deck_list.map do |deck_name|
            SDBM.open(deck_name)
          end
        end

        # デッキからカードを引く
        # @return [void]
        def card_draw(deck_name)
        end

        # カードをデッキに追加する
        # @param [String] deck_name デッキ名
        # @param [String] password デッキ編集パスワード
        # @param [String] card 追加するカードの内容
        # @return [void]
        def card_add(deck_name, password, card)
        end

        # カードをデッキから削除する
        # @param [String] deck_name デッキ名
        # @param [String] password デッキ編集パスワード
        # @param [String] card_id 追加するカードの ID
        # @return [void]
        def card_del(deck_name, password, card_id)
        end

        # デッキを新規に作成する
        # @param [String] deck_name デッキ名
        # @return [void]
        def deck_new(deck_name)
        end

        # 山札モードの時、デッキを初期化する
        # @param [String] deck_name デッキ名
        # @return [void]
        def deck_shuffle(deck_name)
        end

        # デッキの内容を全て出力する
        # @param [String] deck_name デッキ名
        # @param [String] method 出力方法(メールなど)
        # @param [Array] args 出力方法に依存する追加オプション
        # @return [void]
        def deck_export(deck_name, method, args*)
        end

        # デッキを削除する
        # @param [String] deck_name デッキ名
        # @param [String] password デッキ編集パスワード
        # @return [void]
        def deck_destroy(deck_name, password)
        end

        # デッキの情報を出力する
        # @param [String] deck_name デッキ名
        # @return [void]
        def deck_info(deck_name)
        end

        # デッキからカードを引くモードを変更する
        # モードは「山札モード」と「ランダムモード」の2つ
        # 山札　　: 既に引いたカードを記憶しておき、出ていないカードを引く
        # ランダム: 毎回ランダムにカードを引く
        # @param [String] deck_name デッキ名
        # @return [void]
        def draw_mode(deck_name)
        end

        # ヘルプを表示する
        # @return [void]
        def help
        end
      end
    end
  end
end
