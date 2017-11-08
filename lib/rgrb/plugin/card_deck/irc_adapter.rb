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

        match(/-initialize[ 　]+([A-z0-9]+)/, method: :deck_initialize)
        match(/[ 　]+([A-z0-9]+)/, method: :card_draw)
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

        # デッキからカードを引く
        # @return [void]
        def card_draw(m, deck_name)
          m.target.send(@generator.card_draw(m.channel.name, deck_name), true)
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
