require Vagrant.source_root.join('plugins/commands/plugin/command/root').to_s

module VagrantPlugins
  module Bindler
    module PluginCommand
      class Root < CommandPlugin::Command::Root
        def initialize(argv, env)
          super

          # Override the built in `plugin list` command to output project specific
          # plugins information
          @subcommands.register(:list) do
            require_relative "list"
            Bindler::PluginCommand::List
          end

          @subcommands.register(:bundle) do
            require_relative "bundle"
            Bindler::PluginCommand::Bundle
          end
        end
      end
    end
  end
end
