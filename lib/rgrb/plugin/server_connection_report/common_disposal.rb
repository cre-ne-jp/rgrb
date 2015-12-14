# vim: fileencoding=utf-8

require 'cinch'

require 'rgrb/plugin/util/notice_on_each_channel'
require 'rgrb/plugin/util/logging'
require 'rgrb/plugin/server_connection_report/constants'
require 'rgrb/plugin/server_connection_report/generator'
require 'rgrb/plugin/server_connection_report/common_disposal'

module RGRB
  module Plugin
    module ServerConnectionReport
      # サーバリレー監視プラグイン アダプター共通モジュール
      #
      # サーバの接続状態が変化したとき、各デーモンで共通な処理を処理する。
      module CommonDisposal
        include Cinch::Plugin
        include Util::NoticeOnEachChannel
        include Util::Logging

        # メッセージを送信するチャンネルのリスト
        attr_reader :channels_to_send

        set(plugin_name: 'ServerConnectionReport::CommonDisposal')
        self.prefix = ''

        def initialize(*)
          super
          config_data = config[:plugin]
          @channels_to_send = config_data['ChannelsToSend'] || []

          @generator = Generator.new
          @generator.root_path = config[:root_path]
          @generator.configure(config[:plugin])
        end

        # サーバ接続メッセージを NOTICE する
        # @param [Cinch::Message] m メッセージ
        # @param [String] server サーバ
        # @return [void]
        def _joined(m, server)
          if m.server
            log_incoming(m)
            sleep 1
            notice_on_each_channel(@generator.joined(server, m.time))
          end
        end

        # サーバ切断メッセージを NOTICE する
        # @param [Cinch::Message] m メッセージ
        # @param [String] server サーバ
        # @param [String] comment コメント
        # @return [void]
        def _disconnected(m, server, comment)
          if m.server
            log_incoming(m)
            notice_on_each_channel(
              @generator.disconnected(server, m.time, comment)
            )
          end
        end

        # サーバーへの接続が完了したとき、情報を集める
        # @param [Cinch::Message] m メッセージ
        # @return [void]
        def _connected(m)
          sleep 1
          @generator.connection_datas = {
            host: bot.host,
            nick: bot.nick,
            network: bot.irc.isupport['NETWORK']
          }
        end
      end
    end
  end
end
