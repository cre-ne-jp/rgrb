# vim: fileencoding=utf-8

module RGRB
  module Plugin
    module Util
      # プラグインのログ記録関連メソッドを集めたモジュール。
      module Logging
        private

        def self.included(by)
          name = by.to_s.split('::').last
          require "rgrb/plugin/util/logging-#{name.to_snake}"
        end
      end
    end
  end
end

class String
  def to_snake
    self
      .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      .gsub(/([a-z\d])([A-Z])/, '\1_\2')
      .tr('-', '_')
      .downcase
  end

  def to_camel
    self.split('_').map {|w| w[0] = w[0].upcase; w }.join
  end
end
