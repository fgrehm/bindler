require "bundler/gem_tasks"

task :clean do
  sh 'rm -f pkg/*.gem'
end

task :install_vm do
  Bundler.with_clean_env do
    sh "cd development && vagrant ssh -c 'vagrant plugin uninstall vundler && vagrant plugin install /vagrant/pkg/vundler-*.gem'"
  end
end

desc 'Rebuild plugin and install on Vagrant dev VM'
task :deploy => [:clean, :build, :install_vm]
