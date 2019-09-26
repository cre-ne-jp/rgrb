# frozen_string_literal: true
# vim: fileencoding=utf-8

require_relative '../spec_helper'

require 'rgrb/plugins_loader'
require 'rgrb/config'

module RGRB::Plugin; end

describe RGRB::PluginsLoader do
  let(:plugin_names) { %w(DiceRoll Keyword) }

  let(:generators) {
    plugin_names.map { |name| RGRB::Plugin.const_get("#{name}::Generator") }
  }

  let(:rgrb_config) {
    RGRB::Config.new('test', {'IRCBot' => {}, 'Plugins' => plugin_names})
  }
  let(:plugins_loader) { described_class.new(rgrb_config) }

  let(:wrong_config) {
    RGRB::Config.new('test', {'IRCBot' => {}, 'Plugins' => ['MissingPlugin']})
  }
  let(:wrong_plugins_loader) { described_class.new(wrong_config) }

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
