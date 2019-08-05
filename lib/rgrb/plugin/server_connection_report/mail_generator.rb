# vim: fileencoding=utf-8
# frozen_string_literal: true

require 'rgrb/version'
require 'rgrb/plugin_base/generator'

require 'stringio'
require 'mail'
require 'lumberjack'

module RGRB
  module Plugin
    # サーバーリレー監視プラグイン
    module ServerConnectionReport
      # メール生成を司るクラス
      class MailGenerator
        include PluginBase::Generator

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

        # メール生成器を初期化する
        def initialize(*)
          super

          @subject = ''
          @body = ''

          @irc_host = ''
          @irc_nick = ''
          @irc_network = ''

          @mail_config = {}
          @to = 'root@localhost'
        end

        # 設定データを解釈してプラグインの設定を行う
        # @param [Hash] config_data 設定データのハッシュ
        # @return [self]
        def configure(config_data)
          mail_config = config_data['Mail']
          if mail_config
            smtp_config = mail_config['SMTP']
            if smtp_config
              @mail_config = symbolize_keys(smtp_config).
                reject { |_, value| value.nil? }
            end

            to_config = mail_config['To']
            @to = to_config if to_config
          end

          self
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
            logger.error("メールテンプレート #{path} の読み込みに失敗しました")

            # 再送出
            raise e
          end

          logger.warn("メールテンプレート #{path} の読み込みが完了しました")

          self
        end

        # 指定された名前のメールテンプレートファイルを読み込む
        # @param [String] name テンプレート名。これに .txt が付加されて読み込まれる。
        # @return [self]
        # @raise [MailTemplateLoadError] 読み込めなかった場合に発生する
        def load_mail_template_by_name(name)
          load_mail_template_file("#{@data_path}/#{name}.txt")
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
        def generate(server, status, time, message = '')
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
            from:    '%{nick} on %{network} <rgrb-%{nick}@%{host}>',
            subject: @subject,
            body:    @body
          }.each do |key, value|
            mail[key] = value % data_parts
          end

          mail
        end

        private

        # Hashのキーをシンボルに変えたものを返す
        # @param [Hash] hash 変換元のハッシュテーブル
        # @return [Hash]
        def symbolize_keys(hash)
          hash.
            map { |key, value| [key.to_sym, value] }.
            to_h
        end
      end
    end
  end
end
