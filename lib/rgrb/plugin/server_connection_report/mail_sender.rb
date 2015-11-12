# vim: fileencoding=utf-8

require 'mail'

module RGRB
  module Plugin
    # サーバーリレー監視プラグイン
    module ServerConnectionReport
      # メール送信を司るクラス
      class MailSender
        # 送信データを初期化する
        # @param [Hash] config
        # @option [String] to 送信先
        # @option [Hash] smtp 送信に利用するSMTPサーバーの設定
        def initialize(config)
          if(config['smtp'])
            Mail.defaults do
              delivery_method(:smtp, config['smtp'])
            end
          end
          @to = config['to'] || 'root@localhost'
          if(config['address'])
            @address = config['address']
          else
            # error
            @address = 'return@example.com'
          end
        end

        # 接続設定を保存する
        # @param [String] :host 接続サーバーのホスト名
        # @param [String] :nick ボットのニックネーム
        # @param [String] :network ネットワーク名
        attr_writer :connection_datas

        # メールを送信する
        # @param [String] server 対象のサーバー
        # @param [Symbol] status サーバーのステータス
        # @param [DateTime] time 接続・切断時間
        # @param [String] message 補足メッセージ
        # @return [String]
        def send(server, status, time, message)
          data_parts = @connection_datas.clone
          data_parts[:server] = server
          data_parts[:message] = message
          data_parts[:status] = case status
          when :joined
            'に参加し'
          when :disconnected
            'から切断され'
          end

          mail = Mail.new
          {
            charset:  'utf-8',
            from:     '%{nick} on %{network} <rgrb-%{nick}@%{host}>',
            to:       @to,
            subject:  'IRC Server "%{server}" Connection Report',
            body:     <<-__EOT__
IRC サーバー接続状態通知

%{network} に接続されている IRC ボット、%{nick} よりお知らせします。
#{time.strftime('%Y年%m月%d日 %H:%M:%S')}、IRC サーバー %{server} がネットワーク%{status}ました。

IRC サーバーより送信されたメッセージ
%{message}
ここまで============================


このメールは汎用 IRC ボット "RGRB" に組み込まれたプラグイン "ServerConnectionReport" により送信されました。
RGRB ver#{RGRB::VERSION}
Development: https://github.com/cre-ne-jp/rgrb

心当たりがない場合は、お手数をですが以下までご連絡いただきますよう、よろしくお願い致します。
IRC ボット "%{nick}" 運営者連絡先: #{@address}

            __EOT__
          }.each do |key, value|
            mail[key] = value % data_parts
          end
puts mail.body
puts mail.to_s
        end
      end
    end
  end
end
