# vim: set ft=ruby :

# MItamae Github Release Tag
MITAMAE_RELEASE_TAG ||= 'v1.7.4'

# Docker Compose Github Release Tag
DOCKER_COMPOSE_RELEASE_TAG ||= '1.24.0'

# MItamae CookBooks
MITAMAE_COOKBOOKS = [
  'cookbooks/apt/default.rb',
  'cookbooks/sudo/default.rb',
  'cookbooks/require/default.rb',
  'cookbooks/docker/default.rb',
  'cookbooks/kubernetes/default.rb',
]
# MItamae Variables
require 'yaml'
YAML.dump({
  'docker' => {
    'compose' => {
      'dest_dir' => '/vagrant/vendor/docker-compose',
    },
  },
}, File.open(File.join(File.expand_path(__dir__), 'vendor', 'mitamae.yaml'), 'w'))

# Download Require Binary
require 'open-uri'
[
  {
    :name => 'mitamae',
    :urls => [
      "https://github.com/itamae-kitchen/mitamae/releases/download/#{MITAMAE_RELEASE_TAG}/mitamae-x86_64-linux",
    ],
  },
  {
    :name => 'docker-compose',
    :urls => [
      "https://github.com/docker/compose/releases/download/#{DOCKER_COMPOSE_RELEASE_TAG}/docker-compose-Linux-x86_64",
    ],
  },
].each {|item|
  base_dir = File.join(File.expand_path(__dir__), 'vendor', item[:name])
  unless File.exist?(base_dir)
    Dir.mkdir(base_dir, 0755)
  end
  item[:urls].each {|url|
    path = File.join(base_dir, File.basename(url))
    unless File.exist?(path)
      p "Download: #{url}"
      open(url) do |file|
        open(path, 'w+b') do |out|
          out.write(file.read)
        end
      end
    end
  }
}

# Require Minimum Vagrant Version
Vagrant.require_version '>= 2.2.4'

# Vagrant Configuration
Vagrant.configure('2') do |config|
  # Require Plugins
  config.vagrant.plugins = ['vagrant-libvirt']

  # Ubuntu 18.04 Box
  config.vm.box = 'ubuntu1804'
  config.vm.box_url = 'https://github.com/takumin/vagrant-box-libvirt-ubuntu/releases/download/v0.0.3/ubuntu-amd64-bionic-libvirt.box'

  # Synced Directory
  if ENV['NFS_MOUNT_DIR'] then
    # NFS Mount
    config.vm.synced_folder ENV['NFS_MOUNT_DIR'], '/vagrant',
      type: 'nfs',
      nfs_version: 4,
      nfs_udp: false
  else
    # Rsync Copy
    config.vm.synced_folder '.', '/vagrant',
      type: 'rsync',
      rsync__exclude: ['.git/']
  end

  # Libvirt Provider Configuration
  config.vm.provider :libvirt do |libvirt|
    # CPU
    libvirt.cpus = 2
    # Memory
    libvirt.memory = 4096
    # Monitor
    libvirt.graphics_type = 'spice'
    libvirt.graphics_ip = '127.0.0.1'
    libvirt.video_type = 'qxl'
    # Network
    libvirt.management_network_mode = 'nat'
    libvirt.management_network_guest_ipv6 = 'no'
  end

  # MItamae Provision
  config.vm.provision 'shell' do |shell|
    shell.name   = 'Provision mitamae'
    shell.env = {
      'no_proxy' => ENV['no_proxy'] || ENV['NO_PROXY'],
      'NO_PROXY' => ENV['no_proxy'] || ENV['NO_PROXY'],
      'ftp_proxy' => ENV['ftp_proxy'] || ENV['FTP_PROXY'],
      'FTP_PROXY' => ENV['ftp_proxy'] || ENV['FTP_PROXY'],
      'http_proxy' => ENV['http_proxy'] || ENV['HTTP_PROXY'],
      'HTTP_PROXY' => ENV['http_proxy'] || ENV['HTTP_PROXY'],
      'https_proxy' => ENV['https_proxy'] || ENV['HTTPS_PROXY'],
      'HTTPS_PROXY' => ENV['https_proxy'] || ENV['HTTPS_PROXY'],
      'UBUNTU_PROXY' => ENV['UBUNTU_PROXY'],
      'UBUNTU_MIRROR' => ENV['UBUNTU_MIRROR'],
      'DOCKER_MIRROR' => ENV['DOCKER_MIRROR'],
      'KUBERNETES_MIRROR' => ENV['KUBERNETES_MIRROR'],
    }
    shell.inline = <<~BASH
      if ! mitamae version > /dev/null 2>&1; then
        install -o root -g root -m 0755 /vagrant/vendor/mitamae/mitamae-x86_64-linux /usr/local/bin/mitamae
      fi
      cd /vagrant
      mitamae local -y vendor/mitamae.yaml helpers/keeper.rb #{MITAMAE_COOKBOOKS.join(' ')}
    BASH
  end

  # Master
  config.vm.define :master do |domain|
    domain.vm.hostname = 'vagrant-master'
  end

  # Worker
  (1..5).each do |i|
    config.vm.define "worker-#{i}" do |domain|
      domain.vm.hostname = "vagrant-worker-#{i}"
    end
  end
end
