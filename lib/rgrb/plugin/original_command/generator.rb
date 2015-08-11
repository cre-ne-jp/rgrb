# vim: fileencoding=utf-8

require 'rgrb/plugin/configurable_generator'

module RGRB
  module Plugin
    # オリジナルコマンド作成プラグイン
    module OriginalCommand
      # OriginalCommand の出力テキスト生成器
      class Generator
        include ConfigurableGenerator

        # 新しい OriginalCommand::Generator インスタンスを返す
        def initialize
          super
        end

        # 設定データを解釈してプラグインの設定を行う
        # @param [Hash] config_data 設定データのハッシュ
        # @return [self]
        def configure(config_data)
          super
          prepare_database

          self
        end

        # オリジナルコマンドを作成する
        # @param [String] nick
        # @param [String] channel
        # @param [String] cmdname
        # @param [String] delkey
        # @param [String] reply
        # @return [String]
        def create(nick, channel, cmdname, delkey, reply)
          #return '[error] 既に同名のコマンドが登録されています。' if @db.cmd_exist?(cmdname)
          #return '[error] コマンド名に使用できない文字が含まれています。' until cmdname == cmdname.match(CMD_RE).to_s
          #return '[error] 削除キーに使用できない文字が含まれています。' until delkey == delkey.match(CMD_RE).to_s

          cmd = @db.write(nick, channel, cmdname, delkey, reply)

          "#{cmdname} を登録しました。変更・削除するための" \
            "削除キー #{delkey} を紛失しないようにしてください。\n" \
            "コマンド応答例: #{cmd[:reply]}"
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
          "#{cmd[:cmdname]} 作者:#{cmd[:nick]}(#{cmd[:channel]}) 登録日:#{cmd[:date]}\n" \
            "コマンド応答例: #{cmd[:reply]}"
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

        # オリジナルコマンドを呼び出して実行します
        # @param [] m
        # @param [String] cmdname
        # @param [String] args
        # @return [false] コマンドが存在しなかった時
        # @return [String] コマンドが存在した時、呼び出した結果
        def cmdcall(m, cmdname, args)
          return until @db.cmd_exist?(cmdname)
          result = @db.read(cmdname).fetch(:reply)
          arg = args.split(/[ 　]+/, result.scan(/%[we]/).size)

          result.gsub(/%[wecdtu1-9%]/) { |match|
            case match
            when '%w'
              arg.shift
            when '%e'
              URI.encode_www_form_component(arg.shift)
            when '%c'
              m.channel.to_s
            when '%d'
              Date.today
            when '%t'
              Time.now.strftime('%T')
            when '%u'
              m.user.nick
            when /%([1-9])/
              Random.rand(1..$1.to_i)
            when '%%'
              '%'
            end
          }
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
