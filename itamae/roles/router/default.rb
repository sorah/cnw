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

include_recipe '../../cookbooks/nftables/default.rb'
include_recipe '../../cookbooks/bird/default.rb'

include_recipe '../../cookbooks/rp-filter/default.rb'
include_recipe '../../cookbooks/linux-ecmp/default.rb'
include_recipe '../../cookbooks/conntrack/default.rb'

include_recipe '../../cookbooks/zabbix-userparameter-autoping/default.rb'

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

