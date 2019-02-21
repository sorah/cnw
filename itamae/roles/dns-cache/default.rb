node.reverse_merge!(
  dns_cache: {
    threads: 2,
    upstream: nil,
    log_queries: false,
    stubs: [],
    outgoing_interfaces: %w(),
    interfaces: %w(0.0.0.0 ::0),
    iface: {
      world: 'ens3',
      mgmt: 'ens4',
      client: %w(ens4 ens5),
    },
  },
  nftables: {
    config_file: false,
  },
)

1.upto(100) do |i|
  node[:dns_cache][:slab] = 2**i
  if node[:dns_cache][:slab] >= node[:dns_cache][:threads]
    break
  end
end

include_cookbook 'mnt-vol'
include_cookbook 'nftables'
include_cookbook 'unbound'
include_cookbook 'zabbix-userparameter-unbound'
include_cookbook 'zabbix-userparameter-autoping'

template '/etc/nftables.conf' do
  owner 'root'
  group 'wheel'
  mode  '0640'
  notifies :run, 'execute[nft -f /etc/nftables.conf]'
end

directory '/mnt/vol/unbound-log' do
  owner 'unbound'
  group 'unbound'
  mode  '0755'
end

link '/var/log/unbound' do
  to '/mnt/vol/unbound-log'
end

template "/etc/unbound/unbound.conf" do
  owner "root"
  group "root"
  mode  "0644"
end

directory "/var/log/unbound" do
  owner "unbound"
  group "unbound"
  mode  "0755"
end

remote_file "/etc/unbound/named.cache" do
  owner 'root'
  group 'root'
  mode  '0644'
end

service "unbound" do
  action [:enable, :start]
end
