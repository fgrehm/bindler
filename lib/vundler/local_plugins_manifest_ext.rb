module VagrantPlugins
  module Bindler
    module LocalPluginsManifestExt
      PLUGINS_JSON_LOOKUP = [
        ENV['VAGRANT_PLUGINS_FILENAME'],
        'vagrant/plugins.json',
        '.vagrant_plugins',
        'plugins.json'
      ].compact

      def bindler_plugins_file
        @bindler_plugins_file ||= PLUGINS_JSON_LOOKUP.map do |path|
          plugins = cwd.join(path)
          plugins if plugins.file?
        end.compact.first
      end

      def bindler_plugins
        @bindler_plugins ||= bindler_plugins_file ? JSON.parse(bindler_plugins_file.read) : {}
      end
    end
  end
end
