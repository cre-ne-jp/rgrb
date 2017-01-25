# vim: fileencoding=utf-8

require 'rgrb/plugin/configurable_generator'
require 'rgrb/plugin/server_connection_report/mail_sender'

module RGRB
  module Plugin
    # サーバーリレー監視プラグイン
    module ServerConnectionReport
      # ServerConnectionReport の出力テキスト生成器
      class Generator
        include ConfigurableGenerator
        # 設定データを解釈してプラグインの設定を行う
        # @param [Hash] config_data 設定データのハッシュ
        # @return [self]
        def configure(config_data)
          super

          @mail = MailSender.new(config_data['Mail'] || {},
                                 config_data[:logger])
          @mail.load_message_template("#{@data_path}/#{config_data['MessageTemplate']}.txt")

          self
        end

        def connection_datas=(datas)
          @mail.connection_datas = datas
        end

        # サーバがネットワークに参加した際のメッセージを返す
        # @param [String] server サーバ名
        # @param [DateTime] time 接続時間
        # @param [String] message メッセージ
        # @return [String]
        def joined(server, time = nil, message = nil)
          common_part = "!! #{server} がネットワークに参加しました"
          @mail.send(server, :joined, time, message)
          message ? "#{common_part} (#{message})" : common_part
        end

        # サーバがネットワークから切断された際のメッセージを返す
        # @param [String] server サーバ名
        # @param [DateTime] time 切断時間
        # @param [String] message メッセージ
        # @return [String]
        def disconnected(server, time = nil, message = nil)
          common_part = "!! #{server} がネットワークから切断されました"
          @mail.send(server, :disconnected, time, message)
          message ? "#{common_part} (#{message})" : common_part
        end
      end
    end
  end
end
