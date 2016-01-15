# vim: fileencoding=utf-8

require 'cinch'
require 'rgrb/plugin/configurable_adapter'
require 'rgrb/plugin/util/logging'

module RGRB
  module Plugin
    # 退出プラグイン
    module Part
      # Part の IRC アダプター
      class IrcAdapter
        include Cinch::Plugin
        include Util::Logging
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
          if !nick || nick.downcase == bot.nick.downcase
            log(m.raw, :incoming, :info)

            if @part_lock.include?(m.channel)
              m.target.send(@locked_message, true)
              log_notice(m.target, @locked_message)
            else
              Channel(m.channel).part(@part_message)
              log("<PART on #{m.channel}> #{@part_message}", :outgoing, :info)
            end
          end
        end
      end
    end
  end
end
