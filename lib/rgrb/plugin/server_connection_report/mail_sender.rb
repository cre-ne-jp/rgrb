# vim: fileencoding=utf-8

require 'stringio'
require 'mail'
require 'lumberjack'

module RGRB
  module Plugin
    # サーバーリレー監視プラグイン
    module ServerConnectionReport
      # メール送信を司るクラス
      class MailSender
        # メールテンプレートの読み込みに失敗した際に発生するエラー
        class MailTemplateLoadError < StandardError; end

        # メールの送信先
        # @return [String]
        attr_reader :to
        # メールの件名
        # @return [String]
        attr_reader :subject
        # メールの本文
        # @return [String]
        attr_reader :body

        # 送信データを初期化する
        # @param [Hash] config 設定
        # @param [Object] logger ロガー
        # @option [String] to 送信先
        # @option [Hash] smtp 送信に利用するSMTPサーバーの設定
        def initialize(config, logger = nil)
          @subject = ''
          @body = ''

          smtp_config = config['SMTP']
          if smtp_config
            @mail_config = symbolize_keys(smtp_config).
              reject { |_, value| value.nil? }
          end

          @to = config['To'] || 'root@localhost'

          @logger = logger || Lumberjack::Logger.new(
            $stdout, progname: self.class.to_s
          )
        end

        # 接続設定を保存する
        # @param [String] :host 接続サーバーのホスト名
        # @param [String] :nick ボットのニックネーム
        # @param [String] :network ネットワーク名
        attr_writer :connection_datas

        # メールのテンプレートを読み込む
        # @param [String] content テンプレートの内容
        # @return [self]
        def load_mail_template(content)
          content_io = StringIO.new(content)

          # 件名を読み込む
          subject_line = content_io.gets
          unless subject_line
            raise MailTemplateLoadError, '件名が含まれていません'
          end

          @subject = subject_line.chomp

          # 1行読み捨てる
          content_io.gets

          if content_io.eof?
            raise MailTemplateLoadError, '本文が含まれていません'
          end

          @body = content_io.read.chomp

          self
        end

        # メールテンプレートファイルを読み込む
        # @param [String] path メールテンプレートファイル（text/plain）のパス
        # @return [self]
        # @raise [MailTemplateLoadError] 読み込めなかった場合に発生する
        def load_mail_template_file(path)
          content = File.read(path, encoding: 'UTF-8')

          begin
            load_mail_template(content)
          rescue => e
            @logger.error("メールテンプレート #{path} の読み込みに失敗しました")

            # 再送出
            raise e
          end

          @logger.warn("メールテンプレート #{path} の読み込みが完了しました")

          self
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
          mail.delivery_method(:smtp, @mail_config)
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
          mail.deliver
        end

        def symbolize_keys(hash)
          hash.map { |key, value|
            [key.to_sym, value]
          }.to_h
        end
        private :symbolize_keys
      end
    end
  end
end
