require Vagrant.source_root.join('plugins/commands/plugin/command/list').to_s

module VagrantPlugins
  module Vundler
    module PluginCommand
      # Override the built in `plugin list` command to output project specific
      # plugins information
      class List < CommandPlugin::Command::List
        include VagrantPlugins::Vundler::Logging

        def execute
          return unless super == 0

          plugins_json = @env.cwd.join('plugins.json')

          if plugins_json.file?
            data = JSON.parse(plugins_json.read)
            vundler_debug "plugins.json data: #{data.inspect}"

            if data.any?
              @env.ui.info "\nProject dependencies:"
              data.each do |plugin|
                if plugin.is_a?(String)
                  display plugin
                else
                  display *plugin.first
                end
              end
            end
          else
            @env.ui.info "\nNo project specific plugins.json file found!"
          end

          # Success, exit status 0
          0
        end

        def display(plugin, version = nil)
          label = "  -> #{plugin}"
          label << " #{version}" if version
          @env.ui.info label
        end
      end
    end
  end
end
