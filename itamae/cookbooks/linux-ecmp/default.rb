execute 'sysctl -p /etc/sysctl.d/90-ecmp.conf' do
  action :nothing
end

file '/etc/sysctl.d/90-ecmp.conf' do
  content "net.ipv4.fib_multipath_use_neigh = 1\nnet.ipv4.fib_multipath_hash_policy = 1\n"
  owner 'root'
  group 'root'
  mode  '0644'

  notifies :run, 'execute[sysctl -p /etc/sysctl.d/90-ecmp.conf]'
end
