include_recipe '../../cookbooks/nsd/default.rb'

node.reverse_merge!(
  internal_dns: {
    zones: {
      :l => "l.#{node.fetch(:site_domain)}",
      :x => "x.#{node.fetch(:site_domain)}",
      :"in-addr.arpa" => node.fetch(:site_rdomain),
    },
  },
  nftables: {
    config_file: nil,
  },
)

zones = node[:internal_dns].fetch(:zones)
node.reverse_merge!(
  dns_cache: {
    stubs: zones.each_value.map { |name| {zone: "#{name}.", addr: '127.0.0.1@10053'} },
  },
)

template "/etc/nsd/nsd.conf" do
  owner 'root'
  group 'root'
  mode  '0644'
end

directory '/var/db/nsd' do
  owner 'nsd'
  group 'root'
  mode  '0755'
end

serial = Time.now.to_i
zones.each do |file, zone|
  template "/var/db/nsd/#{file}.zone" do
    owner 'root'
    group 'root'
    mode  '0755'
    variables zone: "#{zone}.", hosts: node[:hosts_data], serial: serial
    notifies :run, 'execute[nsd-control reload]'
  end
end

service 'nsd' do
  action [:enable, :start]
end

execute 'nsd-control reload' do
  action :nothing
end
