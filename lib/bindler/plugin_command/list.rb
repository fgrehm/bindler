require Vagrant.source_root.join('plugins/commands/plugin/command/list').to_s

module VagrantPlugins
  module Bindler
    module PluginCommand
      # Override the built in `plugin list` command to output project specific
      # plugins information
      class List < CommandPlugin::Command::List
        include VagrantPlugins::Bindler::Logging

        def execute
          return unless super == 0

          if @env.bindler_plugins_file
            bindler_debug "#{@env.bindler_plugins_file} data: #{@env.bindler_plugins.inspect}"

            if @env.bindler_plugins.any?
              @env.ui.info "\nProject dependencies:"
              @env.bindler_plugins.each do |plugin|
                if plugin.is_a?(String)
                  display plugin
                else
                  display *plugin.first
                end
              end
            end
          else
            @env.ui.info "\nNo project specific plugins manifest file found!"
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
