execute 'sysctl -p /etc/sysctl.d/90-no-icmp-redirect.conf' do
  action :nothing
end

remote_file '/etc/sysctl.d/90-no-icmp-redirect.conf' do
  owner 'root'
  group 'root'
  mode  '0644'

  notifies :run, 'execute[sysctl -p /etc/sysctl.d/90-no-icmp-redirect.conf]'
end
