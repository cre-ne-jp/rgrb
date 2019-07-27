# vim: fileencoding=utf-8

require 'rgrb/plugin_base/irc_adapter'
require 'rgrb/plugin/server_connection_report/generator'
require 'rgrb/plugin/server_connection_report/mail_generator'

module RGRB
  module Plugin
    module ServerConnectionReport
      # サーバリレー監視プラグイン アダプター共通メソッドモジュール。
      # サーバの接続状態が変化したとき用の各デーモンで共通な処理を記述する。
      module IrcAdapterMethods
        # 共通で使用する他のモジュールを読み込む
        def self.included(by)
          by.include(PluginBase::IrcAdapter)
        end

        private

        # 生成器を準備する
        # @return [self]
        def prepare_generators
          config_data = config[:plugin]
          @channels_to_send = config_data['ChannelsToSend'] || []

          @generator = Generator.new

          @mail_generator = nil
          if config_data['Mail'] && config_data['MessageTemplate']
            @mail_generator = MailGenerator.new
            @mail_generator.root_path = config[:root_path]
            @mail_generator.logger = config[:logger]
            @mail_generator.configure(config_data)
            @mail_generator.load_mail_template_by_name(
              config_data['MessageTemplate']
            )

            warn('メール送信を行います')
          else
            warn('メール送信を行いません')
          end

          self
        end

        # サーバのネットワークへの参加を通知する
        # @param [Cinch::Message] m メッセージ
        # @param [String] server サーバ
        # @return [self]
        #
        # サーバのネットワークへの参加を NOTICE で通知する。
        # メール送信の設定が行われている場合は、メールの送信も行う。
        def notice_joined(m, server)
          log_incoming(m)
          sleep 1
          send_notice(@channels_to_send, @generator.joined(server))

          if @mail_generator
            mail = @mail_generator.generate(
              server,
              :joined,
              m.time
            )
            mail.deliver
          end

          self
        end

        # サーバのネットワークからの切断を通知する
        # @param [Cinch::Message] m メッセージ
        # @param [String] server サーバ
        # @param [String] comment コメント
        # @return [self]
        #
        # サーバのネットワークからの切断を NOTICE で通知する。
        # メール送信の設定が行われている場合は、メールの送信も行う。
        def notice_disconnected(m, server, comment)
          log_incoming(m)
          send_notice(@channels_to_send, @generator.disconnected(server, comment))

          if @mail_generator
            mail = @mail_generator.generate(
              server,
              :disconnected,
              m.time,
              comment
            )
            mail.deliver
          end

          self
        end

        # IRC ネットワークへの接続情報をメール生成器に設定する
        # @return [self]
        # @note 引数を任意としてあるのは、このメソッドを直接 Cinch の
        #   メッセージハンドラとして指定できるようにするため。
        #
        # サーバーへの接続が完了したときにこのメソッドを呼び出すことで、
        # メールに IRC ネットワークへの接続情報を含めることができる。
        #
        # メール送信の設定が行われていなかった場合は何もしない。
        def set_connection_info(*)
          return self unless @mail_generator

          sleep 1

          @mail_generator.irc_host = bot.host
          @mail_generator.irc_nick = bot.nick
          @mail_generator.irc_network = bot.irc.isupport['NETWORK']

          self
        end
      end
    end
  end
end
