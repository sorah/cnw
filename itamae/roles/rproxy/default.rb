include_role 'base'
include_cookbook 'nginx'

%w(
  default
  wlc
  zabbix
  grafana
).each do |_|
  template "/etc/nginx/conf.d/#{_}.conf" do
    owner 'root'
    group 'root'
    mode  '0644'
    notifies :reload, 'service[nginx]'
  end
end

file "/etc/nginx/htpasswd" do
  content "#{node[:rproxy_htpasswd]}\n"
  owner 'http'
  group 'http'
  mode  '0600'
end

service 'nginx' do
  action [:enable, :start]
end
