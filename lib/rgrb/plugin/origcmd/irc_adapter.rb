# vim: fileencoding=utf-8

require 'cinch'
require 'rgrb/plugin/configurable_adapter'
require 'rgrb/plugin/origcmd/generator'

module RGRB
  module Plugin
    module Origcmd
      # Origcmd の IRC アダプター
      class IrcAdapter
        include Cinch::Plugin
        include ConfigurableAdapter

        set(plugin_name: 'Origcmd')
        self.prefix = '.origcmd'
        match(/create (#{CMD_RE}) (#{CMD_RE})[ 　]+(.+)/, method: :create)
        match(/remove (#{CMD_RE}) (#{CMD_RE})[ 　]+(.+)/, method: :remove)
        match(/show (#{CMD_RE})[ 　]+(.+)/, method: :show)
        match(/edit (#{CMD_RE}) (#{CMD_RE})[ 　]+(.+)/, method: :edit)
        
        match(/\+ (#{CMD_RE}) (#{CMD_RE})[ 　]+(.+)/, method: :create, :prefix => '.oc')
        match(/- (#{CMD_RE}) (#{CMD_RE})[ 　]+(.+)/, method: :remove, :prefix => '.oc')
        match(/\? (#{CMD_RE})[ 　]+(.+)/, method: :show, :prefix => '.oc')
        
        match(/(#{CMD_RE})[ 　]+(.+)/i, method: :cmdcall, :prefix => '&')

        def initialize(*args)
          super
          prepare_generator
        end

        # オリジナルコマンドを設定する
        # .origcmd create CMDNAME DELKEY コマンドの応答
        # @return [void]
        def create(m, args)
          nick = m.user.nick
          channel = m.channel.to_s
          cmdname, delkey, reply = args.split(/[ 　]/, 3)
          mes =
            if cmdname.match(CMD_RE).to_s != cmdname
              'cmdname error'
            elsif delkey.match(CMD_RE).to_s != delkey
              'delkey error'
            else
              @generator.create(nick, channel, cmdname, delkey, reply)
            end

          m.target.send("origcmd[#{nick}]<CREATE>: #{mes}", true)
        end

        # オリジナルコマンドを削除する
        # .origcmd remove CMDNAME DELKEY
        # @return [void]
        def remove(m, cmdname, delkey)
          header = "origcmd[#{m.user.nick}]<REMOVE>: "
          m.target.send(header + @generator.remove(cmdname, delkey), true)
        end

        # オリジナルコマンドの設定内容を表示する
        # .origcmd show CMDNAME
        # @return [void]
        def show(m, cmdname)
          header = "origcmd[#{m.user.nick}]<SHOW>: "
          m.target.send(header + @generator.show(cmdname), true)
        end

        # オリジナルコマンドを編集する(上書き登録する)
        # .origcmd edit CMDNAME DELKEY コマンドの応答
        # @return [void]
        def edit(m, cmdname, delkey, reply)
          nick = m.user.nick
          channel = m.channel.to_s
          header = "origcmd[#{m.user.nick}]<EDIT>: "
          m.target.send(header + @generator.edit(nick, channel, cmdname, delkey, reply), true)
        end

        def cmdcall(m, cmdname, args)
          header = "&cmdname[#{m.user.nick}]: "
          m.target.send(header + @generator.cmdcall(m, cmdname, args), true)
        end
      end
    end
  end
end
