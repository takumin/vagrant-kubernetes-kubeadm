#
# Package
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

package 'kubelet'
package 'kubeadm'
package 'kubectl'
