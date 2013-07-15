module VagrantPlugins
  module Vundler
    class PluginNotFoundError < Vagrant::Errors::VagrantError
      error_key(:plugin_not_found_error)
    end
  end
end
