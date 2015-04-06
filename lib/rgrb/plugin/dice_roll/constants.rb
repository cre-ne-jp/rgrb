# vim: fileencoding=utf-8

module RGRB
  module Plugin
    module DiceRoll
      # アラビア数字による数を表す正規表現
      NUM_RE = /[1-9]/
      NUMS_RE = /[1-9]\d*/
      # ひらがなによる数を表す正規表現
      KANA_NUM_RE = /[あかさたなはまやら]/
      KANA_NUMS_RE = /[あかさたなはまやら][あかさたなはまやらわ]*/
    end
  end
end
