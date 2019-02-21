node.reverse_merge!(
  vpn_router: {
    primary_ip: nil,
    primary_ip6: nil,
    vpns: {
    },
    iface: { # for various rules
      world: 'ens3',
      core: 'ens5',
      mgmt: 'ens4',
    },
    vpn_rtb4: {
      default: false,
      static: nil,
    },
    vpn_rtb6: {
      default: false,
      static: nil,
    },
  },
  nftables: {
    config_file: nil,
  },
)

include_cookbook 'nftables'
include_cookbook 'strongswan'
include_cookbook 'iproute2'
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

template '/etc/bird.conf.d/vpn.conf' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[birdc configure]'
end



template '/etc/strongswan.d/charon.conf' do
  owner 'root'
  group 'root'
  mode  '0644'
end

template '/etc/strongswan.d/charon/connmark.conf' do
  owner 'root'
  group 'root'
  mode  '0644'
end

template '/etc/strongswan.d/charon/bypass-lan.conf' do
  owner 'root'
  group 'root'
  mode  '0644'
end

directory '/usr/share/cnw/vpn-router' do
  owner 'root'
  group 'root'
  mode  '0755'
end

remote_file '/usr/share/cnw/vpn-router/ipsec-updown.sh' do
  owner 'root'
  group 'root'
  mode  '0755'
end

remote_file '/usr/share/cnw/vpn-router/ipsec-updown-privileged.sh' do
  owner 'root'
  group 'root'
  mode  '0755'
end

remote_file '/etc/sudoers.d/ipsec-updown' do
  owner 'root'
  group 'root'
  mode  '0600'
end

execute 'strongswan reload' do
  command 'ipsec reload && ipsec rereadsecrets'
  action :nothing
end

template '/etc/ipsec.secrets' do
  owner 'root'
  group 'root'
  mode  '0640'
  notifies :run, 'execute[strongswan reload]'
end

template '/etc/ipsec.conf' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[strongswan reload]'
end

service 'strongswan' do
  action [:enable, :start]
end

service 'bird' do
  action [:enable, :start]
end


