node.reverse_merge!(
  fluentd: {
    config_path: '/etc/fluent/fluent.conf',
  },
)
gem_package 'fluentd'

user 'fluentd' do
  system_user true
end

directory '/etc/fluent' do
  owner 'root'
  group 'root'
  mode  '0755'
end

directory '/var/lib/fluentd' do
  owner 'fluentd'
  group 'fluentd'
  mode  '0755'
end

directory '/var/lib/fluentd/buffer' do
  owner 'fluentd'
  group 'fluentd'
  mode  '0755'
end

directory '/var/log/fluentd' do
  owner 'fluentd'
  group 'fluentd'
  mode  '0755'
end


template '/etc/systemd/system/fluentd.service' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[systemctl daemon-reload]'
end
