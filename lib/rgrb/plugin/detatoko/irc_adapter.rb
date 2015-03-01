# vim: fileencoding=utf-8

require 'cinch'
require 'rgrb/plugin/detatoko/generator'

module RGRB
  module Plugin
    module Detatoko
      # Detatoko の IRC アダプター
      class IrcAdapter
        include Cinch::Plugin

        set(plugin_name: 'Detatoko')
        self.prefix = '.d'
        match(/s(\d{,2})([^\+][ 　]|$)/i, method: :skill_decision)
        match(/s(\d{,2})\+(\d{,2})/i, method: :skill_decision)
        match(/(v|m)st/i, method: :stigma)
        match(/(v|m)bet/, method: :badend)

        def initialize(*args)
          super

          @generator = Generator.new
          @header = "でたとこサーガ "
        end

        # スキルランクから判定値を得る
        # @return [void]
        def skill_decision(m, skill_rank, solid = 0)
          header = "#{@header}[#{m.user.nick}]<判定値>: "
          message = @generator.skill_decision(skill_rank.to_i, solid.to_i)
          m.target.send(header + message, true)
        end

        # 烙印(p.63)を得る
        # @return [void]
        def stigma(m, tcode)
          header = "#{@header}[#{m.user.nick}]<#{type_conv(tcode)}力烙印>: "
          message = @generator.stigma(tcode)
          m.target.send(header + message, true)
        end

        # バッドエンド表(p.65)を振る
        # @return [void]
        def badend(m, tcode)
          header = "#{@header}[#{m.user.nick}]<#{type_conv(tcode)}力バッドエンド>: "
          message = @generator.badend(tcode)
          m.target.send(header + message, true)
        end

        # 体力・気力コードを対応する日本語に変換する
        # @param [String] tcode 体力・気力コード
        # @return [String]
        def type_conv(tcode)
          case tcode
          when 'v'
            '体'
          when 'm'
            '気'
          end
        end
        private :type_conv
      end
    end
  end
end
