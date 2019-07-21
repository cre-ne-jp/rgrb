# vim: fileencoding=utf-8

require 'rgrb/irc_plugin'
require 'rgrb/plugin/configurable_adapter'

module RGRB
  module Plugin
    # 退出プラグイン
    module Part
      # Part の IRC アダプター
      class IrcAdapter
        include IrcPlugin
        include ConfigurableAdapter

        set(plugin_name: 'Part')
        match(/part(?:-(\w+))?$/, method: :part)

        def initialize(*args)
          super

          config_data = config[:plugin] || {}
          @part_message =
            config_data['PartMessage'] || 'ご利用ありがとうございました'
          @locked_message =
            config_data['LockedMessage'] || 'このチャンネルで .part は使えません。'
          @part_lock = config_data['PartLock'] || []
        end

        # コマンドを発言されたらそのチャンネルから退出する
        # @param [Cinch::Message] m 送信されたメッセージ
        # @param [String] nick 指定されたニックネーム
        # @return [void]
        def part(m, nick)
          log_incoming(m)

          if !nick || nick.downcase == bot.nick.downcase
            if @part_lock.include?(m.channel)
              send_notice(m.target, @locked_message)
            else
              Channel(m.channel).part(@part_message)
              log_part(m.channel, @part_message)
            end
          end
        end
      end
    end
  end
end
