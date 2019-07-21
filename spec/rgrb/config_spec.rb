# vim: fileencoding=utf-8

require_relative '../spec_helper'

require 'rgrb/config'

describe RGRB::Config do
  let(:root_path) { File.expand_path('config_data', File.dirname(__FILE__)) }
  let(:irc_bot_config) do
    {
      'Host' => 'irc.example.net',
      'Port' => 6667,
      'Password' => 'pa$$word',
      'Nick' => 'rgrb_cinch',
      'User' => 'rgrb',
      'Realname' => '汎用ボット RGRB'
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

  let(:config) do
    described_class.new('test', config_data)
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

  describe '.#config_id_to_path' do
    context 'rgrb' do
      subject { described_class.config_id_to_path('rgrb', root_path) }
      it { should eq("#{root_path}/rgrb.yaml") }
    end

    context '../attack' do
      it do
        expect { described_class.config_id_to_path('../attack', root_path) }.
          to raise_error(ArgumentError)
      end
    end

    context 'trpg/../attack' do
      it do
        expect { described_class.config_id_to_path('trpg/../attack', root_path) }.
          to raise_error(ArgumentError)
      end
    end
  end

  describe '.#load_yaml_file' do
    let(:config_from_file) do
      root_path = File.expand_path('config_data', File.dirname(__FILE__))
      described_class.load_yaml_file('rgrb', root_path)
    end

    describe '#irc_bot' do
      it 'IRC ボット設定のハッシュと等しい' do
        expect(config_from_file.irc_bot).to eq(irc_bot_config)
      end
    end

    describe '#plugins' do
      it 'プラグイン名の配列と等しい' do
        expect(config_from_file.plugins).to eq(plugin_names)
      end
    end

    describe '#plugin_config' do
      it 'プラグイン設定と等しい' do
        expect(config_from_file.plugin_config).to eq(plugin_config)
      end
    end
  end
end
