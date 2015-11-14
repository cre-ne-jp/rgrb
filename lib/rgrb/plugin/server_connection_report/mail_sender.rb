# vim: fileencoding=utf-8

require 'mail'
require 'lumberjack'

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
              delivery_method(:smtp, config['SMTP'])
            end
          end
          @to = config['To'] || 'root@localhost'

          @logger = Lumberjack::Logger.new(
            $stdout, progname: self.class.to_s
          )
        end

        # 接続設定を保存する
        # @param [String] :host 接続サーバーのホスト名
        # @param [String] :nick ボットのニックネーム
        # @param [String] :network ネットワーク名
        attr_writer :connection_datas

        # メールのテンプレートを読み込む
        # @param [String] path テンプレートファイル(text/plain)のパス
        # @return [void]
        def load_message_template(path)
          begin
            template = File.read(path, encoding: 'UTF-8')
            @logger.warn("メールテンプレート #{path} の読み込みが完了しました")
          rescue => e
            @logger.error("メールテンプレート #{path} の読み込みに失敗しました")
            @logger.error(e)
          end

          line_flag = :first
          template.each_line do |line|
            case line_flag
            when :first
              # 1行目は件名
              line_flag = :second
              @subject = line.chomp
            when :second
              # 2行目は破棄
              line_flag = :body
              @body = ''
            when :body
              # 3行目以降は本文
              @body << line
            end
          end
        end

        # メールを送信する
        # @param [String] server 対象のサーバー
        # @param [Symbol] status サーバーのステータス
        # @param [DateTime] time 接続・切断時間
        # @param [String] message 補足メッセージ
        # @return [String]
        def send(server, status, time, message)
          data_parts = @connection_datas.clone
          data_parts[:time] = time.strftime('%Y年%m月%d日 %H:%M:%S')
          data_parts[:server] = server
          data_parts[:message] = message
          data_parts[:rgrb_version] = RGRB::VERSION
          data_parts[:status1], data_parts[:status2] = case status
          when :joined
            ['に参加し', '接続']
          when :disconnected
            ['から切断され', '切断']
          end

          mail = Mail.new
          mail['charset'] = 'utf-8'
          mail['to']      = @to
          {
            from:     '%{nick} on %{network} <rgrb-%{nick}@%{host}>',
            subject:  @subject,
            body:     @body
          }.each do |key, value|
            mail[key] = value % data_parts
          end
puts "Subject: #{mail.subject}\n"
puts mail.body
puts mail.to_s
        end
      end
    end
  end
end
