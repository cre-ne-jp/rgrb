# vim: fileencoding=utf-8
# frozen_string_literal: true

require 'rgrb/version'

require 'stringio'
require 'mail'
require 'lumberjack'

module RGRB
  module Plugin
    # サーバーリレー監視プラグイン
    module ServerConnectionReport
      # メール生成を司るクラス
      class MailGenerator
        # メールテンプレートの読み込みに失敗した際に発生するエラー
        class MailTemplateLoadError < StandardError; end

        # メールの件名
        # @return [String]
        attr_accessor :subject
        # メールの本文
        # @return [String]
        attr_accessor :body

        # ボットの接続先ホスト名
        # @return [String]
        attr_accessor :irc_host
        # ボットのニックネーム
        # @return [String]
        attr_accessor :irc_nick
        # ボットの接続先ネットワーク
        # @return [String]
        attr_accessor :irc_network

        # メールの送信先
        # @return [String]
        attr_reader :to

        # 送信データを初期化する
        # @param [Hash] config 設定
        # @param [Object?] logger ロガー
        # @option [String] to 送信先
        # @option [Hash] smtp 送信に利用するSMTPサーバーの設定
        def initialize(config, logger = nil)
          @subject = ''
          @body = ''

          @irc_host = ''
          @irc_nick = ''
          @irc_network = ''

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

        STATUS_1 = {
          joined: 'に参加し',
          disconnected: 'から切断され'
        }.freeze

        STATUS_2 = {
          joined: '接続',
          disconnected: '切断'
        }.freeze

        # メールの内容を生成する
        # @param [String] server 対象のサーバー
        # @param [Symbol] status サーバーのステータス
        # @param [DateTime] time 接続・切断時間
        # @param [String] message 補足メッセージ
        # @return [MailData]
        def generate(server, status, time, message)
          data_parts = {
            host: @irc_host,
            nick: @irc_nick,
            network: @irc_network,
            time: time.strftime('%Y年%m月%d日 %H:%M:%S'),
            server: server,
            message: message,
            rgrb_version: RGRB::VERSION,
            status1: STATUS_1[status],
            status2: STATUS_2[status]
          }

          mail = Mail.new
          mail.delivery_method(:smtp, @mail_config)
          mail.charset = 'utf-8'
          mail.to      = @to
          {
            from:     '%{nick} on %{network} <rgrb-%{nick}@%{host}>',
            subject:  @subject,
            body:     @body
          }.each do |key, value|
            mail[key] = value % data_parts
          end

          mail
        end

        # Hashのキーをシンボルに変えたものを返す
        # @param [Hash] hash 変換元のハッシュテーブル
        # @return [Hash]
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
