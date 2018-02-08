# vim: fileencoding=utf-8

require 'uri'
require 'rgrb/plugin/configurable_generator'

module RGRB
  module Plugin
    # AntiSpam プラグイン
    module AntiSpam
      # AntiSpam の出力テキスト生成器
      class Generator
        include ConfigurableGenerator

        def initialize
          super

          @channels = {}
          @flags = {}
        end

        # 設定データを解釈してプラグインの設定を行う
        # @param [Hash] config_data 設定データのハッシュ
        # @return [self]
        def configure(config_data)
          @config = {
            mode: :notice,
            count: config_data['Count'] || 3,
            limit: config_data['Limit'] || 2,
            reset: (config_data['ResetTime'] || 1800).to_i
          }

          self
        end

        # チャンネルに JOIN したら、そのチャンネルの参加者を記録する
        # @param [Cinch::Message] m
        # @return [void]
        def join(m)
          if m.user == m.bot
            @channels[m.channel.name] = m.channel.users.keys.map do |user|
              user.nick
            end
          else
            @channels[m.channel.name] << m.user.nick
          end
        end

        # 自身がチャンネルから退出したら、そのチャンネルの情報を削除する
        # 他の誰かなら、チャンネル情報からその人の NICK を削除する
        # @param [Cinch::Message] m
        # @return [void]
        def leaving(m)
          if m.user == m.bot
            @channels.delete(m.channel.name)
          else
            @channels[m.channel.name].delete(m.user.nick)
          end
        end

        # 発言を監視し、チャンネル参加者のNICKを含む数を数える
        # 発言は半角空白で分割する
        # @param [Cinch::Message]
        # @return [void]
        def privmsg(m)
          channel = m.channel.name
          counter = 0
          m.message.split(' ').each do |part|
            counter += 1 if @channels[channel].include?(part)
          end

          return unless @config[:count] <= counter
          if @flags.include?(m.user.nick)
            if @flags[m.user.nick][:date] + @config[:reset] < m.time
              @flags[m.user.nick] = {date: m.time, count: 1}
            elsif @flags[m.user.nick][:count] >= @config[:limit]
              pp 'LIMIT OVER!'
            else
              @flags[m.user.nick][:count] += 1
            end
          else
            @flags[m.user.nick] = {date: m.time, count: 1}
          end
        end

        # デバッグ用
        # @return [void]
        def check
          pp @channels
        end
      end
    end
  end
end
