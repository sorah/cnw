node.reverse_merge!(
  rp_filter: 2,
)

execute 'sysctl -p /etc/sysctl.d/90-rp_filter.conf' do
  action :nothing
end

file '/etc/sysctl.d/90-rp_filter.conf' do
  content "net.ipv4.conf.all.rp_filter = #{node[:rp_filter]}\n"
  owner 'root'
  group 'root'
  mode  '0644'

  notifies :run, 'execute[sysctl -p /etc/sysctl.d/90-rp_filter.conf]'
end
