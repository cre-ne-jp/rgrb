# vim: fileencoding=utf-8

require_relative '../spec_helper'

require 'rgrb/config'
require 'rgrb/plugin/dice_roll'
require 'rgrb/plugin/keyword'
require 'rgrb/plugin/random_generator'

module RGRB
  # 設定クラス
  class Config
    public :snakecase
  end
end

describe RGRB::Config do
  let(:irc_bot_config) do
    {
      'Host' => 'irc.example.net',
      'Port' => 6667,
      'Password' => 'pa$$word',
      'Nick' => 'rgrb_cinch',
      'User' => 'rgrb_cinch',
      'Realname' => '汎用ダイスボット RGRB'
    }
  end
  let(:plugin_names) { %w(DiceRoll Keyword RandomGenerator) }
  let(:config_data) {
    {
      'IRCBot' => irc_bot_config,
      'Plugins' => plugin_names
    }
  }

  let(:config_empty) { described_class.new({}) }
  let(:config) do
    described_class.new(config_data)
  end

  describe '#irc_bot' do
    it 'IRC ボット設定のハッシュと等しい' do
      expect(config.irc_bot).to eq(irc_bot_config)
    end
  end

  describe '#plugins' do
    context '正常に指定した場合' do
      it '指定したプラグインのクラスの配列と等しい' do
        expect(config.plugins).to eq(
          [
            RGRB::Plugin::DiceRoll,
            RGRB::Plugin::Keyword,
            RGRB::Plugin::RandomGenerator
          ]
        )
      end
    end

    context '存在しないプラグインを指定した場合' do
      it do
        expect { described_class.new({}, {}, ['hoge']) }.to raise_error
      end
    end
  end

  describe '#snakecase (private)' do
    context '""' do
      subject { config_empty.snakecase('') }
      it { should eq('') }
    end

    context '"cre"' do
      subject { config_empty.snakecase('cre') }
      it { should eq('cre') }
    end

    context '"RandomGenerator"' do
      subject { config_empty.snakecase('RandomGenerator') }
      it { should eq('random_generator') }
    end

    context '"IRCBot"' do
      subject { config_empty.snakecase('IRCBot') }
      it { should eq('ircbot') }
    end
  end
end
