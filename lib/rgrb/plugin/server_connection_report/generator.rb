# vim: fileencoding=utf-8

require 'mail'
require 'pp'

module RGRB
  module Plugin
    # サーバーリレー監視プラグイン
    module ServerConnectionReport
      # ServerConnectionReport の出力テキスト生成器
      class Generator
        # 設定データを解釈してプラグインの設定を行う
        # @param [Hash] config_data 設定データのハッシュ
        # @return [self]
        def configure(config_data)
#          mailconf = config_data['mail']

#          Mail.defaults do
#            from    'RGRB (%{nick}) <rgrb-%{nick}@%{server}>'
#            to      mailconf['to']
#            subject 'IRC Server %{server} Connection Report'
#            delivery_method(:smtp, mailconf['smtp'])
#          end
        end

        # サーバがネットワークに参加した際のメッセージを返す
        # @param [String] server サーバ名
        # @param [String] message メッセージ
        # @return [String]
        def joined(server, message = nil)
          common_part = "!! #{server} がネットワークに参加しました"
          sendmail message ? "#{common_part} (#{message})" : common_part
        end

        # サーバがネットワークから切断された際のメッセージを返す
        # @param [String] server サーバ名
        # @param [String] message メッセージ
        # @return [String]
        def disconnected(server, message = nil)
          common_part = "!! #{server} がネットワークから切断されました"
          sendmail message ? "#{common_part} (#{message})" : common_part
        end

        # メールを送信する
        # @param [String] message 送信内容
        # @return [String]
        def sendmail(message)
          sendmes = <<-__EOT__
IRC サーバ　接続状態通知
: #{Date.now}

          __EOT__
#          mail = Mail.new
#          mail.body = sendmes % {nick: m.}
#          mail.deliver

          message
        end
      end
    end
  end
end
