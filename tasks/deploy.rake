task :clean do
  sh 'rm -f pkg/*.gem'
end

task :install_vm do
  Bundler.with_clean_env do
    sh "cd development && vagrant ssh -c 'vagrant plugin uninstall bindler && vagrant plugin install /vagrant/pkg/bindler-*.gem'"
  end
end

desc 'Rebuild plugin and install on Vagrant dev VM'
task :deploy => [:clean, :build, :install_vm]
