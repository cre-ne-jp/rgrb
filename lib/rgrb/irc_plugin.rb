# vim: fileencoding=utf-8

require 'cinch'

module RGRB
  module IrcPlugin
    def self.included(by)
      by.include(Cinch::Plugin)
      by.include(Plugin::Util::Logging)
    end
  end
end
