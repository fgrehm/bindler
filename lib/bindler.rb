require_relative "bindler/version"
require_relative "bindler/plugin"
require_relative "bindler/logging"
require_relative 'bindler/plugin_not_found_error'
require_relative "bindler/local_plugins_manifest_ext"
require_relative "bindler/bend_vagrant"

module Bindler
  TESTED_VAGRANT_VERSIONS = ['>= 1.2', '< 1.4.0']
  VagrantVersionError = Class.new(RuntimeError)
end
