#
# Repository
#

apt_keyring 'Google Cloud Packages Automatic Signing Key <gc-team@google.com>' do
  finger '54A647F9048D5688D7DA2ABE6A030B21BA07F4FB'
end

apt_repository 'Kubernetes Repository' do
  path '/etc/apt/sources.list.d/kubernetes.list'
  entry [
    {
      :default_uri => 'https://apt.kubernetes.io',
      :mirror_uri  => "#{ENV['KUBERNETES_MIRROR'] || node[:kubernetes_repository]}",
      :suite       => 'kubernetes-xenial',
      :components  => [
        'main',
      ],
    },
  ]
  notifies :run, 'execute[apt-get update]', :immediately
end

execute 'apt-get update' do
  action :nothing
end

#
# Package
#

package 'kubelet'
package 'kubeadm'
package 'kubectl'

#
# Package
#

%w(kubeadm kubectl).each do |cmd|
  unless File.exist?("/etc/bash_completion.d/#{cmd}") then
    local_ruby_block "#{cmd} completion bash" do
      block do
        result = run_command(["#{cmd}", 'completion', 'bash'])

        if result.success? then
          File.open("/etc/bash_completion.d/#{cmd}", 'w', 0644) do |f|
            f.write(result.stdout)
          end
        end
      end
    end
  end
end
