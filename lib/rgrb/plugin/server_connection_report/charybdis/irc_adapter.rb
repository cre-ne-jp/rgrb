# vim: fileencoding=utf-8

require 'rgrb/plugin/server_connection_report/constants'
require 'rgrb/plugin/server_connection_report/irc_adapter_methods'

module RGRB
  module Plugin
    module ServerConnectionReport
      # Charybdis 用サーバリレー監視プラグイン。
      #
      # サーバの接続状態が変化したときに Oper ユーザーに送信される PRIVMSG
      # を解析する。
      # したがって、基本的にボットが Oper であることが必要である。
      #
      # 送信元を指定するオプション AllowedSenders にサーバアドレスを追加
      # し、受信するメッセージを絞る。
      module Charybdis
        # ServerConnectionReport::Charybdis の IRC アダプター
        class IrcAdapter
          include ServerConnectionReport::IrcAdapterMethods

          # サーバーがネットワークに参加したときのメッセージを表す正規表現
          NETJOIN_RE =
            /^\*\*\* Notice -- Netjoin #{HOSTNAME_RE} <-> (#{HOSTNAME_RE})/o
          # サーバーがネットワークから切断されたときのメッセージを表す
          # 正規表現
          NETSPLIT_RE =
            /^\*\*\* Notice -- Netsplit #{HOSTNAME_RE} <-> (#{HOSTNAME_RE}) \(.+?\) \((.+)\)/o

          set(plugin_name: 'ServerConnectionReport::Charybdis')
          self.prefix = ''
          self.react_on = :notice

          match(NETJOIN_RE, method: :joined)
          match(NETSPLIT_RE, method: :disconnected)

          # サーバーへの接続が完了したときの処理
          listen_to(:'002', method: :set_connection_info)

          # IRC アダプタを初期化する
          def initialize(*)
            super

            prepare_generators
          end

          # ネットワークにあるサーバが参加したときの処理
          # @param [Cinch::Message] m メッセージ
          # @param [String] server サーバ
          # @return [void]
          #
          # サーバのネットワークへの参加を NOTICE で通知する。
          # メール送信の設定が行われている場合は、メールの送信も行う。
          def joined(m, server)
            notice_joined(m, server) if m.server
          end

          # ネットワークからあるサーバが切断されたときの処理
          # @param [Cinch::Message] m メッセージ
          # @param [String] server サーバ
          # @param [String] comment コメント
          # @return [void]
          #
          # サーバのネットワークからの切断を NOTICE で通知する。
          # メール送信の設定が行われている場合は、メールの送信も行う。
          def disconnected(m, server, comment)
            notice_disconnected(m, server, comment) if m.server
          end
        end
      end
    end
  end
end
