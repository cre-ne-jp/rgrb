# vim: fileencoding=utf-8

require_relative '../../spec_helper'

require 'rgrb/plugin_base/generator'
require 'rgrb/plugin_base/adapter'
require 'rgrb/plugin_base/adapter_options'
require 'rgrb/plugin_base/irc_adapter'
require 'rgrb/plugin_base/discord_adapter'

module RGRB
  module Plugin
    module TestPlugin
      class Generator
        include PluginBase::Generator

        attr_reader :logger
        attr_reader :name

        alias default_configure configure

        def configure(config_data)
          @name = config_data['name']
        end
      end

      class IrcAdapter
        include PluginBase::IrcAdapter

        attr_reader :generator

        def initialize(*)
          # 何もしない
        end

        def call_prepare_generator
          prepare_generator
        end

        def config
          PluginBase::AdapterOptions.new(
            'test',
            '/home/rgrb',
            {
              'name' => 'RGRB'
            },
            nil
          )
        end
      end

      class DiscordAdapter
        include PluginBase::DiscordAdapter

        attr_reader :generator
        attr_reader :logger

        def initialize(*)
          @logger = Lumberjack::Logger.new(
            $stdout, progname: File.basename($PROGRAM_NAME)
          )
        end

        def call_prepare_generator
          prepare_generator
        end

        def config
          PluginBase::AdapterOptions.new(
            'test',
            '/home/rgrb',
            {
              'name' => 'RGRB'
            },
            nil
          )
        end
      end
    end
  end
end

describe RGRB::PluginBase::Generator do
  let(:generator) { RGRB::Plugin::TestPlugin::Generator.new }

  describe '#root_path=' do
    let(:root_path) { '/home/rgrb' }
    let(:data_path) { '/home/rgrb/data/test_plugin' }

    let(:generator_set_root_path) {
      generator.root_path = root_path
      generator
    }

    it 'root_path を正しく設定する' do
      expect(generator_set_root_path.root_path).to eq(root_path)
    end

    it 'data_path を正しく設定する' do
      expect(generator_set_root_path.data_path).to eq(data_path)
    end
  end

  describe '#data_path=' do
    let(:data_path) { '/home/rgrb/data2' }
    let(:generator_set_data_path) {
      generator.data_path = data_path
      generator
    }

    it 'data_path を正しく設定する' do
      expect(generator_set_data_path.data_path).to eq(data_path)
    end
  end

  describe '#configure' do
    it '自身を返す' do
      expect(generator.default_configure).to be(generator)
    end
  end
end

describe RGRB::PluginBase::IrcAdapter do
  let(:irc_adapter) { RGRB::Plugin::TestPlugin::IrcAdapter.new }
  let(:root_path) { '/home/rgrb' }

  describe '#prepare_generator (private)' do
    it 'true が返る' do
      expect(irc_adapter.call_prepare_generator).to be(true)
    end

    it '@generator のクラスが正しい' do
      irc_adapter.call_prepare_generator
      expect(irc_adapter.generator.class).to be(RGRB::Plugin::TestPlugin::Generator)
    end

    it '@generator.root_path= で正しく設定される' do
      irc_adapter.call_prepare_generator
      expect(irc_adapter.generator.root_path).to eq(root_path)
    end

    it 'プラグインの設定が反映される' do
      irc_adapter.call_prepare_generator
      expect(irc_adapter.generator.name).to eq('RGRB')
    end

    it 'ロガーが正しく設定される' do
      irc_adapter.call_prepare_generator
      expect(irc_adapter.generator.logger).to be(irc_adapter)
    end
  end
end

describe RGRB::PluginBase::DiscordAdapter do
  let(:discord_adapter) { RGRB::Plugin::TestPlugin::DiscordAdapter.new }
  let(:root_path) { '/home/rgrb' }

  describe '#prepare_generator (private)' do
    it 'true が返る' do
      expect(discord_adapter.call_prepare_generator).to be(true)
    end

    it '@generator のクラスが正しい' do
      discord_adapter.call_prepare_generator
      expect(discord_adapter.generator.class).to be(RGRB::Plugin::TestPlugin::Generator)
    end

    it '@generator.root_path= で正しく設定される' do
      discord_adapter.call_prepare_generator
      expect(discord_adapter.generator.root_path).to eq(root_path)
    end

    it 'プラグインの設定が反映される' do
      discord_adapter.call_prepare_generator
      expect(discord_adapter.generator.name).to eq('RGRB')
    end

    it 'ロガーが正しく設定される' do
      discord_adapter.call_prepare_generator
      expect(discord_adapter.generator.logger).to be(discord_adapter.logger)
    end
  end
end
