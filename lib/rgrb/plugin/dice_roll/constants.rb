# vim: fileencoding=utf-8

module RGRB
  module Plugin
    module DiceRoll
      NUM_RE = /[1-9]/
      # アラビア数字による複数桁の数を表す正規表現
      NUMS_RE = /[1-9]\d*/
      KANA_NUM_RE = /[あかさたなはまやら]/
      # ひらがなによる複数桁の数字を表す正規表現
      KANA_NUMS_RE = /[あかさたなはまやら][あかさたなはまやらわ]*/
    end
  end
end
