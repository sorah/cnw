node.reverse_merge!(
  postgresql_server: {
    root: '/mnt/vol/postgres',
  },
)

include_recipe '../../cookbooks/mnt-vol/default.rb'

##

include_recipe '../../cookbooks/nginx/default.rb'
include_recipe '../../cookbooks/php-fpm/default.rb'

##

include_recipe '../../cookbooks/postgresql-server/default.rb'
include_recipe '../../cookbooks/zabbix-server/default.rb'

template "#{node[:postgresql_server][:root]}/data/pg_hba.conf" do
  source 'templates/var/lib/postgres/data/pg_hba.conf'
  owner 'postgres'
  group 'postgres'
  mode  '0600'
  notifies :reload, 'service[postgresql.service]'
end

directory '/etc/zabbix/zabbix_server.conf.d' do
  owner 'root'
  group 'root'
  mode  '0755'
end

template '/etc/zabbix/zabbix_server.conf' do
  owner 'root'
  group 'zabbix-server'
  mode  '0640'
end

template "/etc/nginx/conf.d/zabbix.conf" do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :reload, 'service[nginx]'
end

##

include_recipe '../../cookbooks/grafana/default.rb'

template '/etc/grafana.ini' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :restart, 'service[grafana]'
end

template '/etc/nginx/conf.d/grafana.conf' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :reload, 'service[nginx]'
end

execute 'grafana-cli plugins install alexanderzobnin-zabbix-app' do
  not_if 'grafana-cli  plugins ls|grep alexanderzobnin-zabbix-app'
end

##

remote_file '/usr/share/cnw/scripts/zabbix-server-initdb' do
  owner 'root'
  group 'root'
  mode  '0744'
end

remote_file '/usr/share/cnw/scripts/grafana-initdb' do
  owner 'root'
  group 'root'
  mode  '0744'
end


execute '/usr/share/cnw/scripts/zabbix-server-initdb' do
  not_if 'test -e /mnt/vol/initialized.zabbix-server'
end

execute '/usr/share/cnw/scripts/grafana-initdb' do
  not_if 'test -e /mnt/vol/initialized.grafana'
end

##

include_recipe '../../cookbooks/zabbix-userparameter-autoping/default.rb'

##

service 'zabbix-server-pgsql' do
  action [:enable, :start]
end

service 'grafana' do
  action [:enable, :start]
end

service 'php-fpm' do
  action [:enable, :start]
end

service 'nginx' do
  action [:enable, :start]
end

