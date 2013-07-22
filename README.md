# Vundler
Dead easy Vagrant plugins management (not to be confused with [vim's Vundle](https://github.com/gmarik/vundle)),
think of it as soon-to-be "[Bundler](http://bundler.io/) for Vagrant".

## WARNING
This is highly experimental and things might go wrong. It basically does some
[heavy monkey patching](lib/vundler/bend_vagrant.rb) on Vagrant's core and should
not be considered "production-ready". Please keep that in mind and be ready to
[revert Vundler's installation](#help-things-are-falling-apart) in case things
go crazy.


## Installation
Make sure you have Vagrant 1.2+ and run:

```
vagrant plugin install vundler
vagrant vundler setup
```

## Usage
Add one of `plugins.json`, `.vagrant_plugins`, or `vagrant/plugins.json`
to your project root. The first matching file will be used as your
project's plugins.json file.

```json
[
  "vagrant-lxc",
  {"vagrant-cachier": "0.2.0"}
]
```

And run `vagrant plugin bundle` to install missing dependencies:

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
vundler (0.0.4)

Project dependencies:
  -> vagrant-lxc
  -> vagrant-cachier 0.2.0
```


## Help! Things are falling apart!
First bring back Vagrant's default `plugins.json` file:

```
mv $HOME/.vagrant.d/{global-,}plugins.json
```

And then remove the `require 'vundler'` from your `$HOME/.vagrant.d/Vagrantfile`.

## How does it work?
Have a look at [this blog post](http://fabiorehm.com/blog/2013/07/15/vundler-dead-easy-plugin-management-for-vagrant/).

# Development

```bash
git clone vundler
cd vundler
bundle install

# Add some changes...
bundle exec rake build
vagrant plugin install pkg/vundler-VERSION.gem
```

## Contributing
1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
