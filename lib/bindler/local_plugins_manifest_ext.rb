module VagrantPlugins
  module Bindler
    module LocalPluginsManifestExt
      PLUGINS_LOOKUP = [
        ENV['VAGRANT_PLUGINS_FILENAME'],
        'vagrant/plugins.json',
        'vagrant/plugins.yml',
        '.vagrant_plugins.json',
        '.vagrant_plugins.yml',
        'plugins.json',
        'plugins.yml'
      ].compact

      def bindler_plugins_file
        @bindler_plugins_file ||= PLUGINS_LOOKUP.map do |path|
          plugins = cwd.join(path)
          plugins if plugins.file?
        end.compact.first
      end

      def bindler_plugins
        @bindler_plugins ||= bindler_plugins_file ? YAML.parse(bindler_plugins_file.read).to_ruby : {}
      end
    end
  end
end
