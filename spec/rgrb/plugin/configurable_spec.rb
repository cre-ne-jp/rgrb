# vim: fileencoding=utf-8

require_relative '../../spec_helper'

require 'rgrb/plugin/configurable_generator'
require 'rgrb/plugin/configurable_adapter'

module RGRB
  module Plugin
    module TestPlugin
      class Generator
        include ConfigurableGenerator

        attr_reader :root_path
        attr_reader :data_path
        attr_reader :logger
        attr_reader :name

        alias default_configure configure

        def configure(config_data)
          @name = config_data['name']
          @logger = config_data[:logger]
        end
      end

      class IrcAdapter
        include ConfigurableAdapter

        attr_reader :generator

        def config
          {
            root_path: '/home/rgrb',
            plugin: {
              'name' => 'RGRB'
            }
          }
        end
      end
    end
  end
end

describe RGRB::Plugin::ConfigurableGenerator do
  let(:generator) { RGRB::Plugin::TestPlugin::Generator.new }
  let(:root_path) { '/home/rgrb' }

  describe '#root_path=' do
    it '正しく設定される' do
      generator.root_path = root_path
      expect(generator.root_path).to eq(root_path)
    end
  end

  describe '@data_path' do
    let(:data_path) { '/home/rgrb/data/test_plugin' }

    it '正しく設定される' do
      generator.root_path = root_path
      expect(generator.data_path).to eq(data_path)
    end
  end

  describe '#configure' do
    it '自身が返る' do
      expect(generator.default_configure).to be(generator)
    end
  end
end

describe RGRB::Plugin::ConfigurableAdapter do
  let(:irc_adapter) { RGRB::Plugin::TestPlugin::IrcAdapter.new }
  let(:send_prepare_generator) { -> { irc_adapter.send(:prepare_generator) } }
  let(:root_path) { '/home/rgrb' }

  describe '#prepare_generator (private)' do
    it 'true が返る' do
      expect(send_prepare_generator.call).to be(true)
    end

    it '@generator のクラスが正しい' do
      send_prepare_generator.call
      expect(irc_adapter.generator.class).to be(RGRB::Plugin::TestPlugin::Generator)
    end

    it '@generator.root_path= で正しく設定される' do
      send_prepare_generator.call
      expect(irc_adapter.generator.root_path).to eq(root_path)
    end

    it 'プラグインの設定が反映される' do
      send_prepare_generator.call
      expect(irc_adapter.generator.name).to eq('RGRB')
    end

    it 'ロガーが正しく設定される' do
      send_prepare_generator.call
      expect(irc_adapter.generator.logger).to be(irc_adapter)
    end
  end
end
