require_relative '../logging'

module VagrantPlugins
  module Vundler
    module VundlerCommand
      class Setup < Vagrant.plugin(2, :command)
        def execute
          if @env.home_path.join('global-plugins.json').file?
            @env.ui.info "Vundler has already been set up!"
            return 0
          end

          # Load current plugins.json file
          plugins_json      = @env.home_path.join('plugins.json')
          plugins_json_data = JSON.parse(plugins_json.read)
          @logger.debug "Current #{plugins_json} data: #{plugins_json_data.inspect}"

          # Gets a list of other plugins that are installed
          @logger.debug "Getting list of installed plugins"
          other_plugins = plugins_json_data['installed'].dup
          other_plugins.delete('vundler')

          # Save other plugins to a separate file
          @logger.debug "Writing #{other_plugins.inspect} to #{@env.home_path.join('global-plugins.json')}"
          @env.home_path.join('global-plugins.json').open("w+") do |f|
            f.write(JSON.dump({'installed' => other_plugins}))
          end

          # Leave only vundler on the global plugins file
          plugins_json_data['installed'] = ['vundler']
          @logger.debug "Writing #{plugins_json_data.inspect} to #{plugins_json}"
          plugins_json.open('w+') do |f|
            f.write(JSON.dump plugins_json_data)
          end

          # Add require to ~/.vagrant.d/Vagrantfile
          vagrantfile          = @env.home_path.join('Vagrantfile')
          vagrantfile_contents = vagrantfile.file? ? vagrantfile.read : ''
          # FIXME: We need to handle emacs / vim file types comments
          vagrantfile_contents = <<-STR
begin
  require 'vundler'
rescue LoadError; end
#{vagrantfile_contents}
          STR
          @logger.debug "Writing to system wide Vagrantfile:\n#{vagrantfile_contents}"
          @env.home_path.join('Vagrantfile').open("w+") do |f|
            f.write vagrantfile_contents
          end

          0
        end
      end
    end
  end
end
