node.reverse_merge!(
  zabbix_userparameter_autoping: {
    destinations: node[:network_tester],
  },
)

execute 'systemctl try-reload-or-restart autoping.service' do
  action :nothing
end

file '/etc/autoping.json' do
  content "#{node[:zabbix_userparameter_autoping][:destinations].to_json}\n"
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[systemctl try-reload-or-restart autoping.service]'
end

remote_file '/usr/bin/zabbix-userparameter-autoping' do
  owner 'root'
  group 'root'
  mode  '0755'
end

remote_file '/usr/bin/zabbix-userparameter-autoping-list' do
  owner 'root'
  group 'root'
  mode  '0755'
end

remote_file '/usr/bin/zabbix-userparameter-autoping-run' do
  owner 'root'
  group 'root'
  mode  '0755'
  notifies :restart, 'service[autoping]'
end

remote_file '/etc/systemd/system/autoping.service' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[systemctl daemon-reload]'
end

remote_file '/etc/zabbix/zabbix_agentd.conf.d/autoping.conf' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :restart, 'service[zabbix-agent]'
end

service 'autoping' do
  action [:enable, :start]
end
