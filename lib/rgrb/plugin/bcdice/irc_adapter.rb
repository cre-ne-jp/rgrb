# vim: fileencoding=utf-8

require 'rgrb/plugin_base/irc_adapter'
require 'rgrb/plugin/bcdice/constants'
require 'rgrb/plugin/bcdice/errors'
require 'rgrb/plugin/bcdice/generator'

module RGRB
  module Plugin
    module Bcdice
      # Bcdice の IRC アダプター
      class IrcAdapter
        include PluginBase::IrcAdapter

        set(plugin_name: 'Bcdice')
        self.prefix = '.bcdice'

        match(BCDICE_RE, method: :bcdice)
        match(/-version/, method: :version)
        match(/-systems/, method: :systems)
        match(/-search-id[\s　]+([^\s　]+)/, method: :search_id)
        match(/-search-name[\s　]+(.+)/, method: :search_name)

        def initialize(*args)
          super

          prepare_generator
          @header = 'BCDice'
        end

        # BCDice でダイスを振る
        # @param [Cinch::Message] m 送信されたメッセージ
        # @param [String] command ダイスコマンド
        # @param [String] specified_game_title 指定されたゲームタイトル
        # @return [void]
        def bcdice(m, command, specified_game_title)
          log_incoming(m)

          # 共通のヘッダ
          header_common = "#{@header}[#{m.user.nick}]"

          result =
            begin
              @generator.bcdice(command, specified_game_title)
            rescue DiceBotNotFound, InvalidCommandError => e
              notice_bcdice_error(m.target, header_common, e)
              return
            end

          # ゲームシステム名を含むヘッダ
          header = "#{header_common}<#{result.game_name}>: "

          send_notice(m.target, result.message, header)
        end

        # git submodule で組み込んでいる BCDice のバージョンを出力する
        # @param [Cinch::Message] m
        # @return [void]
        def version(m)
          log_incoming(m)
          send_notice(m.target, @generator.bcdice_version)
        end

        # BCDice公式サイトのゲームシステム一覧のURLを出力する
        # @param [Cinch::Message] m
        # @return [void]
        def systems(m)
          log_incoming(m)
          send_notice(m.target, @generator.bcdice_systems)
        end

        # BCDiceのゲームシステムをIDで探す
        # @param [Cinch::Message] m
        # @param [String] keyword キーワード
        # @return [void]
        def search_id(m, keyword)
          log_incoming(m)

          message = @generator.bcdice_search_id(
            keyword,
            GameSystemListFormatter::IRC_MESSAGE
          ).message
          send_notice(m.target, message)
        end

        # BCDiceのゲームシステムを名称で探す
        # @param [Cinch::Message] m
        # @param [String] keyword キーワード
        # @return [void]
        def search_name(m, keyword)
          log_incoming(m)

          message = @generator.bcdice_search_name(
            keyword,
            GameSystemListFormatter::IRC_MESSAGE
          ).message
          send_notice(m.target, message)
        end

        private

        # BCDice 関連のエラーを NOTICE する
        # @param [Cinch::Target] target 送信先
        # @param [String] header_common 共通のヘッダ
        # @param [StandardError] error エラー
        # @return [void]
        def notice_bcdice_error(target, header_common, error)
          header = error.respond_to?(:game_name) ?
            "#{header_common}<#{error.game_name}>" : header_common

          send_notice(target, error.message, "#{header}: ")
        end
      end
    end
  end
end
