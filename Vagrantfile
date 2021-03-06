require_relative './lib/system'

VAGRANTFILE_VERSION = '2'.freeze

System.validate_plugins!

ipaddr = ENV['VAGRANT_IPADDRESS'] || '192.168.33.10'
dns_zone = 'matthewcrocco.dev'

Vagrant.configure(VAGRANTFILE_VERSION) do |config|
  config.berkshelf.enabled = true

  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.include_offline = true

  config.vm.box = 'ubuntu/xenial64'
  config.vm.hostname = 'matthewcrocco.us-host'
  config.vm.box_version = '20170622.0.0'
  config.vm.box_check_update = true
  config.ssh.forward_agent = true

  config.vm.synced_folder '.', '/vagrant',
                          type: 'nfs',
                          mount_options: ['rw,context=system_u:object_r:default_t:s0']

  config.vm.synced_folder './code', '/pub',
                          type: 'nfs',
                          mount_options: ['rw,context=system_u:object_r:default_t:s0']

  config.vm.provider 'virtualbox' do |vb|
    vb.name = 'matthewcrocco.us-box'
    vb.customize ['modifyvm', :id, '--memory', System.system_memory / 6]
    vb.customize ['modifyvm', :id, '--cpus', System.cpu_count]
    vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    vb.customize ['modifyvm', :id, '--natdnsproxy1', 'off']
  end

  config.vm.define 'vagrant', autostart: true do |v|
    v.vm.hostname = "vagrant-#{dns_zone}"
    v.vm.network :private_network, ip: "#{ipaddr}"
    v.vm.network :forwarded_port, guest: 8000, host: 8888
    v.hostmanager.aliases = %w[
      www
    ].map { |prefix| "#{prefix}.#{dns_zone}" }
  end

  config.vm.provision :shell, path: './scripts/pre-provision.sh', privileged: true
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = 'cookbooks'
    %w[
      apt
      ohai
      build-essential
      openssl

      chef_nginx

      postgresql
    ].each { |recipe| chef.add_recipe recipe }

    chef.json = {
      postgresql: {
        config_pgtune: {
          db_type: 'web'
        },
        password: {
          postgres: ENV['VAGRANT_PG_PASSWORD'] || (ARGV.any? { |arg| arg.include? 'provision' } && (warn('No postgres password provided! (VAGRANT_PG_PASSWORD)') && '') || '')
        }
      }
    }
  end
  config.vm.provision :shell, path: './scripts/post-provision.sh', privileged: true

  if File.exist?('./scripts/custom.sh')
    config.vm.provision 'shell', path: './scripts/custom.sh'
  end
end
