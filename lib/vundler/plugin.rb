I18n.load_path << File.expand_path(File.dirname(__FILE__) + '/../../locales/en.yml')
I18n.reload!

module VagrantPlugins
  module Vundler
    class Plugin < Vagrant.plugin('2')
      name 'Vundler'

      command("plugin") do
        require_relative 'plugin_command/root'
        PluginCommand::Root
      end

      command("vundler") do
        require_relative 'vundler_command/root'
        VundlerCommand::Root
      end
    end
  end
end
