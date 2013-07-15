require Vagrant.source_root.join('plugins/commands/plugin/command/root').to_s

module VagrantPlugins
  module Vundler
    module PluginCommand
      class Root < CommandPlugin::Command::Root
        def initialize(argv, env)
          super

          # Override the built in `plugin list` command to output project specific
          # plugins information
          @subcommands.register(:list) do
            require_relative "list"
            Vundler::PluginCommand::List
          end

          @subcommands.register(:bundle) do
            require_relative "bundle"
            Vundler::PluginCommand::Bundle
          end
        end
      end
    end
  end
end
