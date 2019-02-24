node.reverse_merge!(
  prometheus: {
    snmp_exporter: {
      use_cookbook_config: true,
    },
  },
)

package 'prometheus-snmp-exporter-bin'

if node[:prometheus][:snmp_exporter][:use_cookbook_config]
  remote_file '/etc/prometheus/snmp.yml' do
    owner 'root'
    group 'root'
    mode  '0644'
    notifies :restart, 'service[prometheus-snmp-exporter.service]', :immediately
  end

  service 'prometheus-snmp-exporter.service' do
    action [:enable, :start]
  end
end
