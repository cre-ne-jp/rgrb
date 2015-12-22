# vim: fileencoding=utf-8

require_relative '../spec_helper'

require 'rgrb/plugins_loader'
require 'rgrb/config'

module RGRB::Plugin; end

describe RGRB::PluginsLoader do
  let(:empty_config) do
    RGRB::Config.new('IRCBot' => {})
  end
  let(:empty_plugins_loader) { described_class.new(empty_config) }

  let(:plugin_names) { %w(DiceRoll Keyword) }
  let(:plugin_path) do
    {
      'DiceRoll' => 'rgrb/plugin/dice_roll',
      'Keyword' => 'rgrb/plugin/keyword'
    }
  end
  let(:generators) do
    plugin_names.map do |name|
      RGRB::Plugin.const_get("#{name}::Generator")
    end
  end
  let(:rgrb_config) do
    RGRB::Config.new('IRCBot' => {}, 'Plugins' => plugin_names)
  end
  let(:plugins_loader) { described_class.new(rgrb_config) }

  let(:wrong_config) do
    RGRB::Config.new('IRCBot' => {}, 'Plugins' => ['MissingPlugin'])
  end
  let(:wrong_plugins_loader) do
    described_class.new(wrong_config)
  end

  describe '#initialize (private)' do
    describe '@plugin_names' do
      it 'プラグイン名の配列に等しい' do
        expect(plugins_loader.instance_variable_get(:@plugin_names)).
          to eq(plugin_names)
      end
    end

    describe '@plugin_paths' do
      it 'プラグインのパスのハッシュに等しい' do
        expect(plugins_loader.instance_variable_get(:@plugin_path)).
          to eq(plugin_path)
      end
    end
  end

  describe '#load_each' do
    context '"Generator"' do
      context '設定が正しい場合' do
        it 'Generator クラスの配列が返る' do
          expect(plugins_loader.load_each('Generator')).
            to eq(generators)
        end
      end

      context '存在しないプラグインが設定されている場合' do
        context 'skip_on_load_error = false' do
          it do
            expect { wrong_plugins_loader.load_each('Generator') }.
              to raise_error(LoadError)
          end
        end

        context 'skip_on_load_error = true' do
          it do
            expect(wrong_plugins_loader.load_each('Generator', true)).
              to eq([])
          end
        end
      end
    end
  end
end
