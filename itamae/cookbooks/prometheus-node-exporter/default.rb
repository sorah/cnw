node.reverse_merge!(
  prometheus: {
    node_exporter: {
      collectors: %w(
        conntrack
        diskstats
        entropy
        filefd
        filesystem
        loadavg
        mdadm
        meminfo
        netdev
        netstat
        sockstat
        stat
        textfile
        time
        uname
        vmstat
        logind
        systemd
      )
    },
  },
)

package 'prometheus-node-exporter'

directory '/var/lib/prometheus-node-exporter' do
  owner 'root'
  group 'root'
  mode  '0755'
end
directory '/var/lib/prometheus-node-exporter/textfile_collector' do
  owner 'root'
  group 'root'
  mode  '0755'
end

template '/etc/systemd/system/prometheus-node-exporter.service' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[systemctl daemon-reload]', :immediately
  notifies :restart, 'service[prometheus-node-exporter.service]', :immediately
end

service 'prometheus-node-exporter.service' do
  action [:enable, :start]
end
