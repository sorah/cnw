include_role 'base'
include_cookbook 'grafana'

template '/etc/grafana.ini' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :restart, 'service[grafana]'
end

service 'grafana' do
  action [:enable, :start]
end
