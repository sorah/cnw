node.reverse_merge!(
  multilib: run_command("grep '^\\[multilib\\]' /etc/pacman.conf", error: false).exit_status == 0,
  in_container: run_command("systemd-detect-virt --container", error: false).exit_status == 0,
  base: {
  },
)

if node[:desired_hostname] && node[:desired_hostname] != node[:hostname]
  execute "set hostname" do
    command "hostnamectl set-hostname #{node[:desired_hostname]}"
  end
  node[:hostname] = node[:desired_hostname]
end

include_cookbook 'arch-wanko-cc'
include_cookbook 'arch-sorah-jp'

directory "/usr/share/cnw" do
  owner 'root'
  group 'root'
  mode  '0755'
end

directory "/usr/share/cnw/scripts" do
  owner 'root'
  group 'root'
  mode  '0755'
end

include_cookbook 'locale'
include_cookbook 'no-icmp-redirect'

include_cookbook 'sshd'

%w(
  sudo
  bind-tools
  sysstat
  dstat
  vim
  mtr
  tcpdump
  gnu-netcat
  socat
  traceroute
  htop
  jq
  git
  ruby
  btrfs-progs
).each do |_|
  package _
end

include_cookbook 'iperf3'

remote_file '/etc/gemrc' do 
  owner 'root'
  group 'root'
  mode  '0644'
end

#if node[:multilib]
#  package "gcc-multilib" do
#  end
#else
#  package "gcc" do
#  end
#end

include_cookbook 'op-user'

template "/etc/systemd/timesyncd.conf" do
  owner 'root'
  group 'root'
  mode  '0644'
end

unless node[:in_container]
  service "systemd-timesyncd" do
    action [:enable, :start]
  end
end

include_cookbook 'prometheus-node-exporter'
include_cookbook 'prometheus-exporter-proxy'

file '/root/.ssh/authorized_keys' do
  action :delete
end
