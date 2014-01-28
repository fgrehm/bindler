# Bindler

Dead easy Vagrant plugins management, think of it as "[Bundler](http://bundler.io/)
for Vagrant".

**NOTICE: This plugin is no longer being maintained, if you are interested on picking up the gem name or wants to continue the work on it please let [@fgrehm](https://github.com/fgrehm) know**.

## WARNING

This is highly experimental and things might go wrong. It basically does some
[heavy monkey patching](lib/bindler/bend_vagrant.rb) on Vagrant's core and should
not be considered "production-ready". Please keep that in mind and be ready to
[revert Bindler's installation](#help-things-are-falling-apart) in case things
go crazy.

## Installation

_The plugin works with Vagrant 1.2 and 1.3 only and will error out if you are using a newer version._

To get the latest version of Bindler simply run the following:

```bash
vagrant plugin install bindler
vagrant bindler setup
```

To install a pre-release or legacy version of the plugin look through the
[Bindler releases page on GitHub](https://github.com/fgrehm/bindler/releases),
download the `bindler-VERSION.gem`, and run the following:

```bash
# Set $VERSION to the version you want to install
VERSION='0.1.4' 

# Assuming you dowloaded the gem to ~/Downloads
vagrant plugin install ~/Downloads/bindler-$VERSION.gem
```

## Changelog
The [Bindler releases page on GitHub](https://github.com/fgrehm/bindler/releases)
gives you a great overview of all the changes that get into every release of Bindler.
You can also view [the commit history](https://github.com/fgrehm/bindler/commits/master)

## Usage
Add a plugin manifest file under one of [these filenames](lib/bindler/local_plugins_manifest_ext.rb#L4-L12). Currently the accepted formats are JSON and YAML. The recommended filenames are `plugins.json` or `plugins.yml`. You can even add your own plugin manifest name using the `$VAGRANT_PLUGINS_FILENAME` variable. The JSON/YAML format plugins as their names (strings) or their name and version (key-value pair):

Example JSON:
```json
[
  "vagrant-lxc",
  {
    "vagrant-cachier": "0.2.0"
  }
]
```

Example YAML:
```yaml
- vagrant-lxc
- vagrant-cachier: 0.2.0
```

In a project with a plugins file you can simply run `vagrant plugin bundle` to
install any missing dependencies:

```
$ vagrant plugin bundle

Installing plugins...
  -> vagrant-lxc already installed
  -> vagrant-cachier (0.2.0)
```

List installed plugins with `vagrant plugin list`:

```
$ vagrant plugin list

vagrant-lxc (0.4.0)
bindler (0.1.1)

Project dependencies:
  -> vagrant-lxc
  -> vagrant-cachier 0.2.0
```


## Help! Things are falling apart!
First bring back Vagrant's default `plugins.json` file:

```
mv $HOME/.vagrant.d/{global-,}plugins.json
```

And then remove the `require 'bindler'` from your `$HOME/.vagrant.d/Vagrantfile`.

## How does it work?
Have a look at [this blog post](http://fabiorehm.com/blog/2013/07/15/vundler-dead-easy-plugin-management-for-vagrant/).

## Contributing

```bash
# Clone the project from origin
git clone https://github.com/fgrhem/bindler

# Fork the project on GitHub and add it as a remote in your local repository
git remote add fork https://github.com/USERNAME/bindler

cd bindler/
bundle install

git checkout -b feature/your-awesome-feature # or fix/your-awesome-bug-fix

# Add and test out your changes
rake build
vagrant plugin install pkg/bindler-VERSION.gem

# Push your changes to the forked branch
git push fork feature/your-awesome-feature # or fix/your-awesome-bug-fix

# Create a pull request on GitHub
```

[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/fgrehm/bindler/trend.png)](https://bitdeli.com/free "Bitdeli Badge")
