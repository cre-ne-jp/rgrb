# vim: fileencoding=utf-8

require 'cinch'
require 'rgrb/plugin/util/notice_multi_lines'

require 'rgrb/../../vendor/BCDice/src/cgiDiceBot'

module RGRB
  module Plugin
    # BCDice のラッパープラグイン
    module Bcdice
      # Bcdice の IRC アダプター
      class IrcAdapter
        include Cinch::Plugin
        include Util::NoticeMultiLines

        set(plugin_name: 'Bcdice')
        self.prefix = '.bcdice'
        match(/[ 　]+([A-z0-9@]+)[ 　]+([A-z0-9]+)/, method: :bcdice)
        match(/-version/, method: :version)

        def initialize(*args)
          super

          @bcdice = CgiDiceBot.new
        end

        # BCDice でダイスを振る
        # @param [Cinch::Message] m 送信されたメッセージ
        # @param [String] command ダイスコマンド
        # @param [String] gameType ゲームタイプ
        # @return [void]
        def bcdice(m, command, gameType = '')
          log_incoming(m)

          result = @bcdice.roll(command, gameType)
          message = result[0].lstrip

          log_notice(m.target, message)
          m.target.send(message, true)
        end

        # git submodule で組み込んでいる BCDice のバージョンを出力する
        # @param [Cinch::Message] m
        # @rturn [void]
        def version(m)
          log_incoming(m)

          message = 'BCDice Commit ID: '
          message += Dir.chdir(File.expand_path(
            '../../../../vendor/BCDice',
            File.dirname(__FILE__)
          )) do |path|
            `git show -s --format=%H`.strip
          end

          log_notice(m.target, message)
          m.target.send(message, true)
        end
      end
    end
  end
end