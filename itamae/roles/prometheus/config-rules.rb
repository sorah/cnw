directory '/etc/prometheus/rules' do
  owner 'root'
  group 'root'
  mode  '0755'
end

node[:prometheus][:rule_files].each do |_|
  template "/etc/prometheus/rules/#{_}.yml" do
    owner 'root'
    group 'root'
    mode  '0644'
    notifies :reload, 'service[prometheus.service]'
  end
end


