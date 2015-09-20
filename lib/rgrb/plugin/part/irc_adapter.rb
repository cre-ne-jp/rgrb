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
        include ConfigurableAdapter
        include Util::Logging

        set(plugin_name: 'Part')
        match(/part(?:-(\w+))?$/, method: :part)

        def initialize(*args)
          super

          config_data = config[:plugin] || {}
          @part_message =
            config_data['PartMessage'] || 'ご利用ありがとうございました'
          @not_part_message = 
            config_data['NotPartMessage'] || 'このチャンネルでは退出コマンドを利用できません'
          @exclude_channels = 
            config_data['ExcludeChannels'].map do |channel|
              channel.downcase
            end
        end

        # コマンドを発言されたらそのチャンネルから退出する
        # @param [Cinch::Message] m 送信されたメッセージ
        # @param [String] nick 指定されたニックネーム
        # @return [void]
        def part(m, nick)
          if @exclude_channels.index(m.channel.name.downcase)
            log_incoming(m)
            m.target.send(@not_part_message, true)
            log_notice(m.target, @not_part_message)
            return
          end

          if !nick || nick.downcase == bot.nick.downcase
            log_incoming(m)
            Channel(m.channel).part(@part_message)
            log("<PART on #{m.channel}> #{@part_message}", :outgoing, :info)
          end
        end
      end
    end
  end
end
