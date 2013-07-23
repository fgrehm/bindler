module VagrantPlugins
  module Vundler
    module LocalPluginsManifestExt
      PLUGINS_JSON_LOOKUP = [
        ENV['VAGRANT_PLUGINS_FILENAME'],
        'vagrant/plugins.json',
        '.vagrant_plugins',
        'plugins.json'
      ].compact

      def vundler_plugins_file
        @vundler_plugins_file ||= PLUGINS_JSON_LOOKUP.map do |path|
          plugins = cwd.join(path)
          plugins if plugins.file?
        end.compact.first
      end

      def vundler_plugins
        @vundler_plugins ||= vundler_plugins_file ? JSON.parse(vundler_plugins_file.read) : {}
      end
    end
  end
end
