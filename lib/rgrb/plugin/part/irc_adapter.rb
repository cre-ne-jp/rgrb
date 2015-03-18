# vim: fileencoding=utf-8

require 'cinch'
require 'rgrb/plugin/configurable_adapter'

module RGRB
  module Plugin
    # 退出プラグイン
    module Part
      # Part の IRC アダプター
      class IrcAdapter
        include Cinch::Plugin
        include ConfigurableAdapter

        set(plugin_name: 'Part')
        match(/part(?:-(\w+))?$/, method: :part)

        def initialize(*args)
          super

          config_data = config[:plugin]
          @part_message =
            config_data['PartMessage'] || 'ご利用ありがとうございました'
        end

        # コマンドを発言されたらそのチャンネルから退出する
        # @param [Cinch::Message] m 送信されたメッセージ
        # @param [String] nick 指定されたニックネーム
        # @return [void]
        def part(m, nick)
          if !nick || nick.downcase == bot.nick.downcase
            log(m.raw, :incoming, :info)
            Channel(m.channel).part(@part_message)
            log("<PART on #{m.channel}> #{@part_message}", :outgoing, :info)
          end
        end
      end
    end
  end
end
