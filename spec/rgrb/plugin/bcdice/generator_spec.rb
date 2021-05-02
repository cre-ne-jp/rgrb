# vim: fileencoding=utf-8

require 'lumberjack'
require_relative '../../../spec_helper'
require 'rgrb/plugin/bcdice/generator'
require 'rgrb/plugin/bcdice/errors'

describe RGRB::Plugin::Bcdice::Generator do
  let(:generator) { described_class.new }

  describe '#bcdice_version' do
    it 'BCDice のバージョンを出力する' do
      expect(generator.bcdice_version).to(
        match(/\ABCDice Version: \d+\.\d+\.\d+/)
      )
    end
  end

  describe '#bcdice' do
    context('ゲームシステムなし') do
      context('無効なコマンド') do
        it '無効なコマンドのエラーが発生する' do
          expect { generator.bcdice('not_found') }.to raise_error(
            RGRB::Plugin::Bcdice::InvalidCommandError,
            'コマンド「not_found」は無効です'
          )
        end
      end

      context('2d6') do
        subject { generator.bcdice('2d6') }

        it 'ゲームシステムとして DiceBot が選ばれる' do
          expect(subject.game_name).to eq('DiceBot')
        end

        it '2d6 の結果が返る' do
          expect(subject.message.start_with?('(2D6) ＞ ')).to be(true)
        end
      end
    end

    context('存在しないゲームシステム') do
      it 'ダイスボットが見つからないことを示すエラーが発生する' do
        expect { generator.bcdice('2d6', 'not_found') }.to raise_error(
          RGRB::Plugin::Bcdice::DiceBotNotFound,
          'ゲームシステム「not_found」は見つかりませんでした'
        )
      end
    end

    context('ソード・ワールド2.0') do
      context('k20') do
        subject { generator.bcdice('k20', 'SwordWorld2.0') }

        it 'ゲームシステムとして「ソード・ワールド2.0」が選ばれる' do
          expect(subject.game_name).to eq('ソードワールド2.0')
        end

        it 'k20 の結果が返る' do
          expect(subject.message.start_with?('KeyNo.20c')).to be(true)
        end
      end
    end
  end

  describe '#bcdice_systems' do
    it 'BCDice公式サイトのゲームシステム一覧のURLを返す' do
      expect(generator.bcdice_systems).to(
        match(/\ABCDice ゲームシステム一覧/)
      )
    end
  end
end
