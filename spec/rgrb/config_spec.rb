# vim: fileencoding=utf-8

require_relative '../spec_helper'

require 'rgrb/config'

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
  let(:keyword_settings) do
    { 'CreSearch' => 'http://cre.jp/search/' }
  end
  let(:plugin_config) do
    {
      'DiceRoll' => nil,
      'Keyword' => keyword_settings,
      'RandomGenerator' => nil
    }
  end
  let(:config_data) do
    {
      'IRCBot' => irc_bot_config,
      'Plugins' => plugin_names,
      'Keyword' => keyword_settings
    }
  end

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
    it 'プラグイン名の配列と等しい' do
      expect(config.plugins).to eq(plugin_names)
    end
  end

  describe '#plugin_config' do
    it 'プラグイン設定と等しい' do
      expect(config.plugin_config).to eq(plugin_config)
    end
  end
end
