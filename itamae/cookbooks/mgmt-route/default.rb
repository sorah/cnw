node.reverse_merge!(
  mgmt_route: {
    enable: false,
    prefixes: {v4: [], v6: []},
    routes: {v4: [], v6: []},
  },
)
template '/usr/bin/cnw-setup-mgmt-route' do
  owner 'root'
  group 'root'
  mode  '0755'
end
remote_file '/etc/systemd/system/cnw-mgmt-route.service' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[systemctl daemon-reload]', :immediately
end

if node[:mgmt_route][:enable]
  service 'cnw-mgmt-route' do
    action :enable
  end
else
  service 'cnw-mgmt-route' do
    action :disable
  end
end


