node[:prometheus][:exporter_proxy][:exporters][:kea_exporter] = {path: '/kea_exporter/metrics', url: 'http://localhost:9547/metrics'}
include_cookbook 'python'

execute 'pip install kea-exporter' do
  not_if "test -e /usr/bin/kea-exporter"
end

# https://github.com/mweinelt/kea-exporter/pull/6
execute 'curl -Lo /usr/lib/python3.*/site-packages/kea_exporter/kea.py https://raw.githubusercontent.com/sorah/kea-exporter/expect_for_subnet_id/kea_exporter/kea.py && [ "_455796a06520e85564e5db90280a5cdf599fd4d853912dd3bc2d2d3deb401670" = "_$(sha256sum /usr/lib/python3.*/site-packages/kea_exporter/kea.py | cut -f1 -d" ")" ]' do
  not_if '[ "_455796a06520e85564e5db90280a5cdf599fd4d853912dd3bc2d2d3deb401670" = "_$(sha256sum /usr/lib/python3.*/site-packages/kea_exporter/kea.py | cut -f1 -d" ")" ]'
end

template '/etc/systemd/system/prometheus-kea-exporter.service' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[systemctl daemon-reload]', :immediately
end

service 'prometheus-kea-exporter.service' do
  action [:enable, :start]
end
