# vim: fileencoding=utf-8

require 'rgrb/plugin_base/discord_adapter'
require 'rgrb/plugin/bcdice/constants'
require 'rgrb/plugin/bcdice/errors'
require 'rgrb/plugin/bcdice/generator'

module RGRB
  module Plugin
    module Bcdice
      # Bcdice の Discord アダプター
      class DiscordAdapter
        include PluginBase::DiscordAdapter

        set(plugin_name: 'Bcdice')
        self.prefix = '.bcdice'

        match(BCDICE_RE, method: :bcdice)
        match(/-version/, method: :version)
        match(/-systems/, method: :systems)
        match(/-search-id ([^\s　]+)/, method: :search_id)
        match(/-search-name (.+)/, method: :search_name)

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
          header_common = "#{@header}[#{m.user.mention}]"

          result =
            begin
              @generator.bcdice(command, specified_game_title)
            rescue DiceBotNotFound, InvalidCommandError => e
              notice_bcdice_error(m.channel, header_common, e)
              return
            end

          # ゲームシステム名を含むヘッダ
          header = "#{header_common}<#{result.game_name}>: "

          send_channel(m.channel, result.message, header)
        end

        # git submodule で組み込んでいる BCDice のバージョンを出力する
        # @param [Cinch::Message] m
        # @return [void]
        def version(m)
          log_incoming(m)

          message = @generator.bcdice_version

          send_channel(m.channel, message)
        end

        # BCDice公式サイトのゲームシステム一覧のURLを出力する
        # @param [Cinch::Message] m
        # @return [void]
        def systems(m)
          log_incoming(m)
          send_channel(m.channel, @generator.bcdice_systems)
        end

        # BCDiceのゲームシステムをIDで探す
        # @param [Cinch::Message] m
        # @param [String] keyword キーワード
        # @return [void]
        def search_id(m, keyword)
          log_incoming(m)

          message = @generator.bcdice_search_id(
            keyword,
            GameSystemListFormatter::MARKDOWN
          )
          send_channel(m.channel, message)
        end

        # BCDiceのゲームシステムを名称で探す
        # @param [Cinch::Message] m
        # @param [String] keyword キーワード
        # @return [void]
        def search_name(m, keyword)
          log_incoming(m)

          message = @generator.bcdice_search_name(
            keyword,
            GameSystemListFormatter::MARKDOWN
          )
          send_channel(m.channel, message)
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
          message = "#{header}: #{error.message}"

          send_channel(target, message)
        end
      end
    end
  end
end
