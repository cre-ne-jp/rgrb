# vim: fileencoding=utf-8

require 'cinch'
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
        self.prefix = '.deck'

        match(/-(?:initialize|set)[\s　]+([A-z0-9]+)/, method: :deck_initialize)
        match(/-destroy[\s　]+([A-z0-9]+)/, method: :deck_destroy)
        match(/-reset[\s　]+([A-z0-9]+)/, method: :deck_reset)
        match(/(?:-draw|)[\s　]+([A-z0-9]+)/, method: :card_draw)
        match(/-count[\s　]+([A-z0-9]+)/, method: :card_count)
#        match(/-info/, method: :deck_info)
#        match(/-help/, method: :help)

        def initialize(*)
          super

          prepare_generator
        end

        # デッキをチャンネルで使えるようにする
        # @return [void]
        def deck_initialize(m, deck_name)
          m.target.send(@generator.deck_initialize(m.channel.name, deck_name), true)
        end

        # 使いかけのデッキを破棄する
        # @return [void]
        def deck_destroy(m, deck_name)
          m.target.send(@generator.deck_destroy(m.channel.name, deck_name), true)
        end

        # デッキをリセットする
        # 既に途中まで使われたデッキを破棄し、新しく初期化する
        # @return [void]
        def deck_reset(m, deck_name)
          deck_destroy(m, deck_name)
          deck_initialize(m, deck_name)
        end

        # デッキからカードを引く
        # @return [void]
        def card_draw(m, deck_name)
          m.target.send(@generator.card_draw(m.channel.name, deck_name), true)
        end

        # デッキに残るカードの枚数を返す
        # @return [void]
        def card_count(m, deck_name)
          m.target.send(@generator.card_count(m.channel.name, deck_name), true)
        end

        # デッキの情報を出力する
        # @param [Cinch::Message] m
        # @param [String] deck_name デッキ名
        # @return [void]
        def deck_info(m, deck_name)
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
