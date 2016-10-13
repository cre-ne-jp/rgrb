# vim: fileencoding=utf-8

require 'cinch'
require 'uri'
require 'rgrb/plugin/configurable_adapter'
require 'rgrb/plugin/card_deck/generator'
require 'rgrb/plugin/util/logging'

module RGRB
  module Plugin
    module CardDeck
      # CardDeck の IRC アダプター
      class IrcAdapter
        include Cinch::Plugin
        include ConfigurableAdapter
        include Util::Logging

        set(plugin_name: 'CardDeck')

        match(/[ 　]+#{DECK_NAME}/, method: :card_draw)
        match(/-add/, method: :card_add)
        match(/-del/, method: :card_del)
        match(/-new/, method: :deck_new)
        match(/-shuffle/, method: :deck_shuffle)
        match(/-export/, method: :deck_export)
        match(/-destroy/, method: :deck_destroy)
        match(/-info/, method: :deck_info)
        match(/-mode/, method: :draw_mode)
        match(/-help/, method: :help)

        def initialize(*)
          super

          prepare_generator
        end

        # デッキからカードを引く
        # @return [void]
        def card_draw(m, deck_name)
          m.target.send(message, true)
        end

        # カードをデッキに追加する
        # @param [Cinch::Message] m
        # @param [String] deck_name デッキ名
        # @param [String] password デッキ編集パスワード
        # @param [String] card 追加するカードの内容
        # @return [void]
        def card_add(m, deck_name, password, card)
        end

        # カードをデッキから削除する
        # @param [Cinch::Message] m
        # @param [String] deck_name デッキ名
        # @param [String] password デッキ編集パスワード
        # @param [String] card_id 追加するカードの ID
        # @return [void]
        def card_del(m, deck_name, password, card_id)
        end

        # デッキを新規に作成する
        # @param [Cinch::Message] m
        # @param [String] deck_name デッキ名
        # @return [void]
        def deck_new(m, deck_name)
        end

        # 山札モードの時、デッキを初期化する
        # @param [Cinch::Message] m
        # @param [String] deck_name デッキ名
        # @return [void]
        def deck_shuffle(m, deck_name)
        end

        # デッキの内容を全て出力する
        # @param [Cinch::Message] m
        # @param [String] deck_name デッキ名
        # @param [String] method 出力方法(メールなど)
        # @param [Array] args 出力方法に依存する追加オプション
        # @return [void]
        def deck_export(m, deck_name, method, args*)
        end

        # デッキを削除する
        # @param [Cinch::Message] m
        # @param [String] deck_name デッキ名
        # @param [String] password デッキ編集パスワード
        # @return [void]
        def deck_destroy(m, deck_name, password)
        end

        # デッキの情報を出力する
        # @param [Cinch::Message] m
        # @param [String] deck_name デッキ名
        # @return [void]
        def deck_info(m, deck_name)
        end

        # デッキからカードを引くモードを変更する
        # モードは「山札モード」と「ランダムモード」の2つ
        # 山札　　: 既に引いたカードを記憶しておき、出ていないカードを引く
        # ランダム: 毎回ランダムにカードを引く
        # @param [Cinch::Message] m
        # @param [String] deck_name デッキ名
        # @return [void]
        def draw_mode(m, deck_name)
        end

        # ヘルプを表示する
        # @param [Cinch::Message] m
        # @return [void]
        def help(m)
        end
      end
    end
  end
end
