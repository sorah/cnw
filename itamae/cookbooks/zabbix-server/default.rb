package "zabbix-server" do
end

package 'zabbix-frontend-php' do
end

package 'net-snmp' do
end

package 'fping' do
end


#sudo -u postgres psql
#  create database zabbix;
#  create role "zabbix-server" with login;
#  create role "http" with login;
#  \q
#sudo -u postgres psql zabbix
#  alter default privileges for role "zabbix-server" in schema public grant all on tables to "zabbix-server";
#  alter default privileges for role "zabbix-server" in schema public grant all on tables to "http";
#  \q

#cd /usr/share/zabbix-server/postgresql
#sudo -u zabbix psql zabbix < schema.sql
#sudo -u zabbix psql zabbix < images.sql
#sudo -u zabbix psql zabbix < data.sql

#connect Zabbix web frontend to /run/postgresql
