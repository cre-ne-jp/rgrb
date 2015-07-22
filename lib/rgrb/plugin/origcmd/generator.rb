# vim: fileencoding=utf-8

require 'uri'
require 'rgrb/plugin/configurable_generator'

module RGRB
  module Plugin
    # オリジナルコマンド作成プラグイン
    module Origcmd
      # Origcmd の出力テキスト生成器
      class Generator
        include ConfigurableGenerator

        # 新しい Origcmd::Generator インスタンスを返す
        def initialize
        end

        # 設定データを解釈してプラグインの設定を行う
        # @param [Hash] config_data 設定データのハッシュ
        # @return [self]
        def configure(config_data)
          dbtype = config_data['DBtype'] || 'sdbm'
          db_initialize

          self
        end

        def db_initialize

        end

        # オリジナルコマンドを作成する
        # @param [String] nick
        # @param [String] channel
        # @param [String] cmdname
        # @param [String] delkey
        # @param [String] reply
        # @return [String]
        def create(nick, channel, cmdname, delkey, reply)
          return '[error] 既に同名のコマンドが登録されています。' if cmdname_exist?

          @db.write(nick, channel, cmdname, delkey, reply)

          "#{cmdname} を登録しました。変更・削除するための" \
            "削除キー #{delkey} を紛失しないようにしてください。\n" \
            "コマンド応答例: &#{cmd[:reply]}"
        end

        # オリジナルコマンドを削除します
        # @param [String] cmdname コマンド名
        # @param [String] delkey 削除キー
        # @return [String]
        def remove(cmdname, delkey)
          return '[error] コマンドが存在しません' until @db.cmd_exist?(cmdname)
          return '[error] 削除キーが一致しません' until check_delkey(cmdname, delkey)

          @db.remove(cmdname)

          "#{cmdname} を削除しました。"
        end

        # オリジナルコマンドの詳細を調べ、応答します
        # @param [String] cmdname
        # @return [String]
        def show(cmdname)
          return '[error] コマンドが存在しません' until @db.cmd_exist?(cmdname)

          cmd = @db.read(cmdname)
          "#{cmd[:cmdname]} 作者:#{cmd[:nick]}(#{cmd[:channel]}) 登録日:#{cmd[:date]}"
        end

        # オリジナルコマンドを上書き作成します
        # @param [String] nick
        # @param [String] channel
        # @param [String] cmdname
        # @param [String] delkey
        # @param [String] reply
        # @return [String]
        def edit(nick, channel, cmdname, delkey, reply)
          remove(cmdname, delkey)
          create(nick, channel, cmdname, delkey, reply)
        end

        def cmdcall(m, cmdname, args)
          return until @db.cmd_exist?(cmdname)
          arg = args.split(/[ 　]/)

          result = @db.read(cmdname).fetch(:reply)
        end
        # コマンドの削除キーが一致するか調べます
        # @param [String] cmdname
        # @param [String] delkey
        # @return [Boolean]
        def check_delkey(cmdname, delkey)
          @db.read(cmdname).fetch(:delkey) == delkey
        end
      end
    end
  end
end
