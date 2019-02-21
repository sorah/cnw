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


include_recipe '../../cookbooks/rp-filter/default.rb'
include_recipe '../../cookbooks/linux-ecmp/default.rb'
include_recipe '../../cookbooks/conntrack/default.rb'

##

include_recipe '../../cookbooks/zabbix-userparameter-autoping/default.rb'

##

include_recipe '../../cookbooks/nftables/default.rb'

template '/etc/nftables.conf' do
  owner 'root'
  group 'wheel'
  mode  '0640'
  notifies :run, 'execute[nft -f /etc/nftables.conf]'
end

##

include_recipe '../../cookbooks/bird/default.rb'

template '/etc/bird.conf.d/default.conf' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[birdc configure]'
end

##

include_recipe '../../cookbooks/fluentd/default.rb'
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


