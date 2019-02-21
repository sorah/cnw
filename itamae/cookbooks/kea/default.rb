execute 'import F1B11BF05CF02E57.pem' do
  user node[:op_user_name]
  command 'gpg -d F1B11BF05CF02E57; gpg --recv-key F1B11BF05CF02E57'
  not_if 'gpg -l F1B11BF05CF02E57'
end

package "kea" do
end

remote_file "/etc/tmpfiles.d/kea.conf" do
  owner 'root'
  group 'root'
  mode  '0644'
end

directory '/run/kea' do
  owner 'root'
  group 'root'
  mode  '0755'
end

remote_file "/etc/systemd/system/kea-dhcp4.service" do
  owner 'root'
  group 'root'
  mode  '0644'

  notifies :run, 'execute[systemctl daemon-reload]'
end

directory "/var/db/kea" do
  owner 'root'
  group 'root'
  mode  '0755'
end

