node.reverse_merge!(
  kea: {
    interfaces: %w(*),
    relay_only: true,
  },
)

include_recipe '../../roles/base/default.rb'

include_recipe '../../cookbooks/mnt-vol/default.rb'

include_recipe '../../cookbooks/kea/default.rb'
include_recipe '../../cookbooks/zabbix-userparameter-kea/default.rb'

conf = {
  Dhcp4: {
    "control-socket" => {
      "socket-type" => "unix",
      "socket-name" => "/run/kea/kea.sock",
    },
    "interfaces-config" => {
      interfaces: node[:kea][:interfaces],
      "dhcp-socket-type" => node[:kea][:relay_only] ? 'udp' : 'raw',
    },
    "lease-database" => {
      type: "memfile",
      persist: true,
      name: "/var/db/kea/dhcp4.leases",
    },
    "expired-leases-processing" => {
      "reclaim-timer-wait-time" => 10,
      "flush-reclaimed-timer-wait-time" => 25,
      "hold-reclaimed-time" => 1800,
      "max-reclaim-leases" => 500,
      "max-reclaim-time" => 250,
      "unwarned-reclaim-cycles" => 2,
    },
    "valid-lifetime" => 10800,
    "renew-timer" => 5400,
    "rebind-timer" => 7200,
    subnet4: [
      {
        subnet: "10.25.0.0/19",
        id: 1,
        pools: [
          pool: "10.25.30.0-10.25.31.250",
        ],
        "option-data" => [
          {
            name: "routers",
            code: 3,
            space: "dhcp4",
            "csv-format" => true,
            data: "10.25.0.1",
          },
          {
            name: "log-servers",
            space: "dhcp4",
            "csv-format" => true,
            data: "10.25.128.3",
          },
          {
            name: "domain-name",
            code: 15,
            space: "dhcp4",
            "csv-format" => true,
            data: "venue.l.#{node.fetch(:site_domain)}",
          }
        ],
        reservations: [
          node[:hosts_data].select { |_| _[:network] == 'lan' && _[:mac] }.map { |_|
            {
              "hw-address" => _[:mac].downcase,
              "ip-address" => _[:ip],
              "hostname"   => "#{_[:name]}.venue.l.#{node.fetch(:site_domain)}",
            }
          }
        ].flatten,
      },
      {
        subnet: "10.25.100.0/24",
        id: 100,
        pools: [
          {
            pool: "10.25.100.50-10.25.100.250",
          },
        ],
        "option-data" => [
          {
            name: "routers",
            code: 3,
            space: "dhcp4",
            "csv-format" => true,
            data: "10.25.100.254",
          },
        ],
      },
      {
        subnet: "10.25.112.0/20",
        id: 112,
        pools: [
          {
            pool: "10.25.113.0-10.25.127.250",
          },
        ],
        "option-data" => [
          {
            name: "routers",
            code: 3,
            space: "dhcp4",
            "csv-format" => true,
            data: "10.25.127.254",
          },
        ],
      },
    ],
    "option-data" => [
      {
        name: "domain-name-servers",
        code: 6,
        space: "dhcp4",
        "csv-format" => true,
        data: "10.25.200.53,10.25.200.54", # comma separated
      },
    ],
  },
  Logging: {
    loggers: [
      {
        name: "kea-dhcp4",
        output_options: [
          {
            output: "/mnt/vol/kea-log/kea.log",
            maxsize: 1000000,
          },
        ],
        severity: "INFO",
      },
    ],
  },
}

directory "/mnt/vol/kea-log" do
  owner 'root'
  group 'root'
  mode  '0755'
end

file "/etc/kea/kea.conf" do
  content "#{conf.to_json}\n"
  owner 'root'
  group 'root'
  mode  '0644'
end

service "kea-dhcp4" do
  action [:enable, :start]
end

