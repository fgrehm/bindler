# WARNING: Monkey patches ahead

Vagrant::Environment.class_eval do
  include VagrantPlugins::Bindler::Logging
  include VagrantPlugins::Bindler::LocalPluginsManifestExt

  # UGLY HACK: This is required because we need to load project specific plugins
  # before the `:environment_load` hook from Vagrant::Environment on [1]. In order
  # to run the hook, Vagrantfile configs have to be parsed [2] to build a
  # Vagrant::Action::Runner [3].
  #
  #   [1] - https://github.com/mitchellh/vagrant/blob/master/lib/vagrant/environment.rb#L135
  #   [2] - https://github.com/mitchellh/vagrant/blob/master/lib/vagrant/environment.rb#L239
  #   [3] - https://github.com/mitchellh/vagrant/blob/master/lib/vagrant/environment.rb#L498-L510
  #
  # DISCUSS: What if Vagrant had another hook that was called before `:environment_load`?
  alias old_hook hook
  def hook(name)
    unless @__custom_plugins_loaded
      if bindler_plugins_file
        bindler_debug 'Loading local plugins...'
        __load_local_plugins
      else
        lookup_paths = VagrantPlugins::Bindler::LocalPluginsManifestExt::PLUGINS_LOOKUP
        bindler_debug "Local plugins manifest file not found, looked into #{lookup_paths.inspect}"
      end

      bindler_debug 'Loading plugins installed globally...'
      __load_global_plugins

      @__custom_plugins_loaded = true
    end
    old_hook name
  end

  # This method loads plugins from `~/.vagrant.d/global-plugins.json` file
  #
  # It is basically a Copy & Paste from Vagrant::Environment#load_plugins [1]
  #
  #   [1] https://github.com/mitchellh/vagrant/blob/master/lib/vagrant/environment.rb#L720-L754
  #
  # DISCUSS: What if vagrant had a way of setting the path for the manifest file
  #          for the whole environment?
  def __load_global_plugins
    # If we're in a Bundler environment, don't load plugins. This only
    # happens in plugin development environments.
    if defined?(Bundler)
      require 'bundler/shared_helpers'
      if Bundler::SharedHelpers.in_bundle?
        @logger.warn("In a bundler environment, not loading environment plugins!")
        return
      end
    end

    # Load the plugins
    plugins_json_file = @home_path.join("global-plugins.json")
    bindler_debug("Loading plugins from: #{plugins_json_file}")
    if plugins_json_file.file?
      data = YAML.parse(plugins_json_file.read).to_ruby
      data["installed"].each do |plugin|
        bindler_info("Loading plugin from global-plugin.json: #{plugin}")
        begin
          Vagrant.require_plugin(plugin)
        rescue Vagrant::Errors::PluginLoadError => e
          @ui.error(e.message + "\n")
        rescue Vagrant::Errors::PluginLoadFailed => e
          @ui.error(e.message + "\n")
        end
      end
    end
  end

  # This method loads plugins from a project specific `plugins.json` file
  def __load_local_plugins
    ARGV.each do |arg|
      if !arg.start_with?("-") && arg == 'bindler'
        bindler_debug 'bindler command detected, setting VAGRANT_NO_PLUGINS to 1'
        ENV["VAGRANT_NO_PLUGINS"] = "1"
        break
      end
    end

    if ENV['VAGRANT_NO_PLUGINS']
      bindler_debug 'VAGRANT_NO_PLUGINS is set to true, skipping local plugins manifest parsing'
      return
    end

    # Prepend our local gem path and reset the paths that Rubygems knows about.
    bindler_debug 'Tweaking GEM_HOME'
    ENV["GEM_PATH"] = "#{local_data_path.join('gems')}#{::File::PATH_SEPARATOR}#{ENV["GEM_PATH"]}"
    ::Gem.clear_paths

    bindler_debug "#{bindler_plugins_file} data: #{bindler_plugins.inspect}"
    bindler_plugins.each do |plugin|
      if plugin.is_a?(String)
        __load_plugin plugin
      else
        __load_plugin *plugin.first
      end
    end

    if @__failed_to_load
      plugins = @__failed_to_load.map do |plugin, version|
        "  -> #{plugin} (#{version || ">= 0"})"
      end
      raise VagrantPlugins::Bindler::PluginNotFoundError, plugins: plugins.join("\n")
    end
  end

  def __load_plugin(plugin, version = nil)
    bindler_debug "Loading #{plugin} (#{version.inspect})"
    gem plugin, version
    Vagrant.require_plugin plugin
  rescue Gem::LoadError
    (@__failed_to_load ||= []) << [plugin, version]
  end
end

require Vagrant.source_root.join('plugins/commands/plugin/state_file').to_s
# Vagrant plugin commands manipulate a StateFile object that keeps track of system
# wide installed plugins. Since bindler is kept separately on `~/.vagrant.d/plugins`,
# we hard code a reference to it over here.
# If we don't do this, Bindler will be uninstalled after a system wide plugin install.
class BindlerStateFile < VagrantPlugins::CommandPlugin::StateFile
  def installed_plugins
    ['bindler'] + @data['installed']
  end
end

require Vagrant.source_root.join('plugins/commands/plugin/command/base').to_s
# The patch makes sure Vagrant's system wide plugin commands manipulates the custom
# configuration file.
VagrantPlugins::CommandPlugin::Command::Base.class_eval do
  alias old_action action
  def action(callable, env=nil)
    env = {
      plugin_state_file: BindlerStateFile.new(@env.home_path.join("global-plugins.json")),
    }.merge(env || {})

    old_action(callable, env)
  end
end

require Vagrant.source_root.join('plugins/commands/plugin/action/install_gem').to_s
# This patch ensures Bindler does not get a reference on `~/.vagrant.d/global-plugins.json`
VagrantPlugins::CommandPlugin::Action::InstallGem.class_eval do
  include VagrantPlugins::Bindler::Logging

  alias old_call call
  def call(env)
    if env[:plugin_name] == 'bindler'
      bindler_debug 'Installing bindler to global plugins file'
      # bindler is the only plugin that should be installed on the global state file
      env[:plugin_state_file] = VagrantPlugins::CommandPlugin::StateFile.new(env[:home_path].join("plugins.json"))
    else
      bindler_debug "Installing #{env[:plugin_name]} to $HOME/.vagrant.d"
    end
    old_call(env)
  end
end
