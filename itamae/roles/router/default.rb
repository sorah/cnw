node.reverse_merge!(
  router: {
    iface: {
      core: 'ens3',
      mgmt: 'ens4',
      down: %w(ens5),
    },
  },
  nftables: {
    config_file: false,
  },
  conntrack: {
    max: 65535,
  }
)

include_cookbook 'nftables'
include_cookbook 'bird'

include_cookbook 'rp-filter'
include_cookbook 'linux-ecmp'
include_cookbook 'conntrack'

include_cookbook 'zabbix-userparameter-autoping'

template '/etc/nftables.conf' do
  owner 'root'
  group 'wheel'
  mode  '0640'
  notifies :run, 'execute[nft -f /etc/nftables.conf]'
end

template '/etc/bird.conf.d/default.conf' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[birdc configure]'
end

service 'bird' do
  action [:enable, :start]
end

