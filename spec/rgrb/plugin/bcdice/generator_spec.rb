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
          expect(subject.game_name).to eq('ソード・ワールド2.0')
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

  describe '#bcdice_search_id' do
    context('存在しないゲームシステム') do
      context('プレーンテキスト') do
        it 'ダイスボットが見つからないことを示すエラーメッセージを返す' do
          expect(generator.bcdice_search_id('not_found').message).to(
            eq('BCDice ゲームシステム検索結果 (ID: not_found): 見つかりませんでした')
          )
        end
      end

      context('Markdown') do
        it 'ダイスボットが見つからないことを示すエラーメッセージを返す' do
          message = generator.bcdice_search_id(
            'not_f**nd',
            RGRB::Plugin::Bcdice::GameSystemListFormatter::MARKDOWN
          ).message
          expect(message).to eq <<~MD.chomp
            **BCDice ゲームシステム検索結果 (ID: *not\\_f\\*\\*nd*)**
            見つかりませんでした
          MD
        end
      end
    end

    context('DICEBOT') do
      context('プレーンテキスト') do
        it 'IDにキーワードが含まれるゲームシステムの一覧を文字列で返す' do
          expect(generator.bcdice_search_id('DICEBOT').message).to(
            eq('BCDice ゲームシステム検索結果 (ID: DICEBOT): DiceBot (DiceBot)')
          )
        end
      end

      context('Markdown') do
        it 'IDにキーワードが含まれるゲームシステムの一覧を文字列で返す' do
          message = generator.bcdice_search_id(
            'DICEBOT',
            RGRB::Plugin::Bcdice::GameSystemListFormatter::MARKDOWN
          ).message
          expect(message).to eq <<~MD.chomp
            **BCDice ゲームシステム検索結果 (ID: *DICEBOT*)**
            * DiceBot (DiceBot)
          MD
        end
      end
    end

    context('sword') do
      context('プレーンテキスト') do
        it 'IDにキーワードが含まれるゲームシステムの一覧を文字列で返す' do
          expect(generator.bcdice_search_id('sword').message).to(
            match(/\ABCDice ゲームシステム検索結果 \(ID: sword\): [.\w]+ \([^)]+\)(?:, [.\w]+ \([^)]+\))*\z/)
          )
        end
      end

      context('Markdown') do
        it 'IDにキーワードが含まれるゲームシステムの一覧を文字列で返す' do
          message = generator.bcdice_search_id(
            'sword',
            RGRB::Plugin::Bcdice::GameSystemListFormatter::MARKDOWN
          ).message
          expect(message).to(
            match(/\A\*\*BCDice ゲームシステム検索結果 \(ID: \*sword\*\)\*\*\n\* [.\w\\]+ \([^)]+\)(?:\n\* [.\w\\]+ \([^)]+\))*\z/)
          )
        end
      end
    end
  end

  describe '#bcdice_search_name' do
    context('存在しないゲームシステム') do
      context('プレーンテキスト') do
        it 'ダイスボットが見つからないことを示すエラーメッセージを返す' do
          expect(generator.bcdice_search_name('not_found').message).to(
            eq('BCDice ゲームシステム検索結果 (名称: not_found): 見つかりませんでした')
          )
        end
      end

      context('Markdown') do
        it 'ダイスボットが見つからないことを示すエラーメッセージを返す' do
          message = generator.bcdice_search_name(
            'not_f**nd',
            RGRB::Plugin::Bcdice::GameSystemListFormatter::MARKDOWN
          ).message
          expect(message).to eq <<~MD.chomp
            **BCDice ゲームシステム検索結果 (名称: *not\\_f\\*\\*nd*)**
            見つかりませんでした
          MD
        end
      end
    end

    context('DICEBOT') do
      context('プレーンテキスト') do
        it '名称にキーワードが含まれるゲームシステムの一覧を文字列で返す' do
          expect(generator.bcdice_search_name('DICEBOT').message).to(
            eq('BCDice ゲームシステム検索結果 (名称: DICEBOT): DiceBot (DiceBot)')
          )
        end
      end

      context('Markdown') do
        it '名称にキーワードが含まれるゲームシステムの一覧を文字列で返す' do
          message = generator.bcdice_search_name(
            'DICEBOT',
            RGRB::Plugin::Bcdice::GameSystemListFormatter::MARKDOWN
          ).message
          expect(message).to eq <<~MD.chomp
            **BCDice ゲームシステム検索結果 (名称: *DICEBOT*)**
            * DiceBot (DiceBot)
          MD
        end
      end
    end

    context('ソード') do
      context('プレーンテキスト') do
        it '名称にキーワードが含まれるゲームシステムの一覧を文字列で返す' do
          expect(generator.bcdice_search_name('ソード').message).to(
            match(/\ABCDice ゲームシステム検索結果 \(名称: ソード\): [.\w]+ \([^)]+\)(?:, [.\w]+ \([^)]+\))*\z/)
          )
        end
      end

      context('Markdown') do
        it '名称にキーワードが含まれるゲームシステムの一覧を文字列で返す' do
          message = generator.bcdice_search_name(
            'ソード',
            RGRB::Plugin::Bcdice::GameSystemListFormatter::MARKDOWN
          ).message
          expect(message).to(
            match(/\A\*\*BCDice ゲームシステム検索結果 \(名称: \*ソード\*\)\*\*\n\* [.\w\\]+ \([^)]+\)(?:\n\* [.\w\\]+ \([^)]+\))*\z/)
          )
        end
      end
    end

    describe '絞り込み検索' do
      shared_examples '絞り込み検索' do
        it '絞り込み検索ができる' do
          keyword1 = keywords_text.split(/[\s　]+/, 2).first
          result1 = generator.bcdice_search_name(keyword1)
          n1 = result1.game_systems.length
          expect(n1).to be > 0

          result2 = generator.bcdice_search_name(keywords_text)
          n2 = result2.game_systems.length
          expect(n2).to be > 0
          expect(n2).to be < n1
        end
      end

      context 'TRPG クトゥルフ' do
        include_examples '絞り込み検索' do
          let(:keywords_text) { 'TRPG クトゥルフ' }
        end
      end

      context 'TRPG　クトゥルフ' do
        include_examples '絞り込み検索' do
          let(:keywords_text) { 'TRPG　クトゥルフ' }
        end
      end

      context 'TRPG　クトゥルフ 新' do
        include_examples '絞り込み検索' do
          let(:keywords_text) { 'TRPG　クトゥルフ 新' }
        end
      end
    end
  end
end
