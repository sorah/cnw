node.reverse_merge!(
  igw_router: {
    iface: {
      world: 'ens3',
      mgmt: 'ens4',
      core: 'ens5',
    },
  },
  nftables: {
    config_file: false,
  },
)


include_cookbook 'rp-filter'
include_cookbook 'linux-ecmp'
include_cookbook 'conntrack'

##

include_cookbook 'nftables'

template '/etc/nftables.conf' do
  owner 'root'
  group 'wheel'
  mode  '0640'
  notifies :run, 'execute[nft -f /etc/nftables.conf]'
end

##

include_cookbook 'bird'

template '/etc/bird.conf.d/default.conf' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[birdc configure]'
end

##

include_cookbook 'fluentd'
gem_package "fluent-plugin-nfct-parser"

template '/etc/fluent/fluent.conf' do
  owner 'root'
  group 'root'
  mode  '0644'
end

##

service 'bird' do
  action [:enable, :start]
end

service 'fluentd' do
  action [:enable, :start]
end


