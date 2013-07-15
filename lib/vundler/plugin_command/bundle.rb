require_relative '../logging'

require Vagrant.source_root.join('plugins/commands/plugin/command/base').to_s
require "rubygems/dependency_installer"

module VagrantPlugins
  module Vundler
    module PluginCommand
      # Based on https://github.com/mitchellh/vagrant/blob/master/plugins/commands/plugin/action/install_gem.rb
      class Bundle < CommandPlugin::Command::Base
        include VagrantPlugins::Vundler::Logging

        def initialize(*)
          super

          if @env.local_data_path
            @local_gems_path = @env.local_data_path.join('gems')
          else
            vundler_debug 'Local data path is not set'
          end
        end

        def execute
          plugins_json = @env.cwd.join('plugins.json')

          if plugins_json.file?
            data = JSON.parse(plugins_json.read)
            vundler_debug "plugins.json data: #{data.inspect}"

            if data.any?
              @env.ui.info('Installing plugins...')

              data.each do |plugin|
                if plugin.is_a?(String)
                  install plugin
                else
                  install *plugin.first
                end
              end
              exit_code = 0
            else
              @env.ui.info('No plugins specified on plugins.json')
            end
          else
            @env.ui.error "No plugins.json found!"
            exit_code = 1
          end

          exit_code
        end

        def gem_helper(path)
          CommandPlugin::GemHelper.new(path)
        end

        def installed_gems
          @installed ||= {}.tap do |installed|
            # Combine project specific gems and global plugins
            gem_helper("#{@local_gems_path}#{::File::PATH_SEPARATOR}#{@env.gems_path}").with_environment do
              Gem::Specification.find_all.each do |spec|
                (installed[spec.name] ||= {})[spec.version.to_s] = spec
              end
            end
          end
        end

        def install(plugin_name, version = nil)
          plugin_name_label = plugin_name
          plugin_name_label += " (#{version})" if version

          versions = installed_gems.fetch(plugin_name, {}).keys
          vundler_debug "Installed versions for #{plugin_name}: #{versions}"

          if (versions.include? version) || (version.nil? && versions.any?)
            @env.ui.info("  -> #{plugin_name_label} already installed")
            return
          end

          gem_helper(@local_gems_path).with_environment do
            installer = Gem::DependencyInstaller.new(:document => [])

            begin
              @env.ui.info("  -> #{plugin_name_label} ")
              installer.install(plugin_name, version)
            rescue Gem::GemNotFoundException
              raise Vagrant::Errors::PluginInstallNotFound,
                :name => plugin_name
            end
          end
        end
      end
    end
  end
end
