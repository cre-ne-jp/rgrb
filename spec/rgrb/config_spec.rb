# vim: fileencoding=utf-8

require_relative '../spec_helper'

require 'rgrb/config'

module RGRB
  class Config
    def snakecase_public(s)
      snakecase(s)
    end
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
  let(:redis_config) do
    {
      'Host' => 'example.net',
      'Port' => 6379,
      'Database' => 0
    }
  end
  let(:plugin_names) {%w(DiceRoll Keyword RandomGenerator)}

  let(:config_empty) {described_class.new({}, {}, [])}
  let(:config) do
    described_class.new(irc_bot_config, redis_config, plugin_names)
  end

  describe '#irc_bot' do
    it 'IRC ボット設定のハッシュと等しい' do
      expect(config.irc_bot).to eq(irc_bot_config)
    end
  end

  describe '#redis' do
    it 'Redis 設定のハッシュと等しい' do
      expect(config.redis).to eq(redis_config)
    end
  end

  describe '#plugins' do
    context '正常に指定した場合' do
      it '指定したプラグインのクラスの配列と等しい' do
        %w(dice_roll keyword random_generator).each do |plugin_name|
          require "rgrb/plugin/#{plugin_name}"
        end

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
      it 'エラーが発生する' do
        expect {described_class.new({}, {}, ['hoge'])}.to raise_error
      end
    end
  end

  describe '#snakecase (private)' do
    context 'empty string' do
      subject {config_empty.snakecase_public('')}
      it {should eq('')}
    end

    context 'cre' do
      subject {config_empty.snakecase_public('cre')}
      it {should eq('cre')}
    end

    context 'RandomGenerator' do
      subject {config_empty.snakecase_public('RandomGenerator')}
      it {should eq('random_generator')}
    end

    context 'IRCBot' do
      subject {config_empty.snakecase_public('IRCBot')}
      it {should eq('ircbot')}
    end
  end
end
