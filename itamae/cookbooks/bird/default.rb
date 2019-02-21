node.reverse_merge!(
  bird: {
    id: nil,
  },
)
raise 'set node[:bird][:id]' unless node[:bird][:id]

package 'bird'

directory '/etc/bird.conf.d' do
  owner 'root'
  group 'root'
  mode  '0755'
end

template '/etc/bird.conf' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[birdc configure]'
end

execute 'birdc configure' do
  command 'bird -c /etc/bird.conf -p && systemctl try-reload-or-restart bird.service'
  action :nothing
end
