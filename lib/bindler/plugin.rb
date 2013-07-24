I18n.load_path << File.expand_path(File.dirname(__FILE__) + '/../../locales/en.yml')
I18n.reload!

module VagrantPlugins
  module Bindler
    class Plugin < Vagrant.plugin('2')
      name 'Bindler'

      command("plugin") do
        require_relative 'plugin_command/root'
        PluginCommand::Root
      end

      command("bindler") do
        require_relative 'bindler_command/root'
        BindlerCommand::Root
      end
    end
  end
end
