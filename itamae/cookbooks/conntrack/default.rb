node.reverse_merge!(
  conntrack: {
    max: 196608,
  }
)

node.reverse_merge!(
  conntrack: {
    buckets: node[:conntrack][:max] / 4,
  }
)
node.reverse_merge!(
  conntrack: {
    expect_max: node[:conntrack][:buckets] / 256,
  },
)

##

package 'conntrack-tools'

remote_file "/etc/sudoers.d/conntrack-tools" do
  owner 'root'
  group 'root'
  mode '0600'
end

##

# Always load nf_conntrack.ko at boot for sysctl.d
file "/etc/modules-load.d/conntrack.conf" do
  content "nf_conntrack\nnf_conntrack_ipv4\nnf_conntrack_ipv6\n"
  owner 'root'
  group 'root'
  mode  '0644'
end

execute 'sysctl -p /etc/sysctl.d/90-conntrack.conf' do
  action :nothing
end

template '/etc/sysctl.d/90-conntrack.conf' do
  owner 'root'
  group 'root'
  mode  '0644'

  notifies :run, 'execute[sysctl -p /etc/sysctl.d/90-conntrack.conf]'
end
