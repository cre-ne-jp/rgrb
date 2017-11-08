# vim: fileencoding=utf-8

require 'cinch'

require 'rgrb/plugin/server_connection_report/constants'
require 'rgrb/plugin/server_connection_report/common_disposal'

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
          include Cinch::Plugin
          include ServerConnectionReport::CommonDisposal

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

          # サーバーがネットワークに参加したときのメッセージを表す正規表現
          match(NETJOIN_RE, method: :joined)
          # サーバーがネットワークから切断されたときのメッセージを表す
          # 正規表現
          match(NETSPLIT_RE, method: :disconnected)
          # サーバーへの接続が完了したときに情報を集める
          listen_to(:'002', method: :connected)

          def initialize(*)
            super
          end

          # サーバ接続メッセージを NOTICE する
          # @param [Cinch::Message] m メッセージ
          # @param [String] server サーバ
          # @return [void]
          def joined(m, server)
            _joined(m,server)
          end

          # サーバ切断メッセージを NOTICE する
          # @param [Cinch::Message] m メッセージ
          # @param [String] server サーバ
          # @param [String] comment コメント
          # @return [void]
          def disconnected(m, server, comment)
            _disconnected(m, server, comment)
          end

          # サーバーへの接続が完了したとき、情報を集める
          # @param [Cinch::Message] m メッセージ
          # @return [void]
          def connected(m)
            _connected(m)
          end
        end
      end
    end
  end
end
