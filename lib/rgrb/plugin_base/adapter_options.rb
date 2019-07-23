# vim: fileencoding=utf-8

module RGRB
  module PluginBase
    AdapterOptions = Struct.new(
      :id,
      :root_path,
      :plugin,
      :logger,
    )
  end
end
