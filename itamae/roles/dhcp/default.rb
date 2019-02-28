node.reverse_merge!(
  kea: {
    subnets: {
    },
    interfaces: %w(*),
    relay_only: true,
  },
)

include_role 'base'

include_cookbook 'mnt-vol'

include_cookbook 'kea'
include_cookbook 'prometheus-kea-exporter'

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
      *(
        node.dig(:kea,:subnets).map do |name, _|
          {
            id: _.fetch(:id),
            subnet: _.fetch(:subnet),
            pools: _.fetch(:pools).map{ |__| {pool: __} },
            "option-data" => [
              {
                name: 'routers',
                code: 3,
                space: 'dhcp4',
                "csv-format" => true,
                data: _.fetch(:router),
              },
              _[:dns] && {
                name: "domain-name-servers",
                code: 6,
                space: "dhcp4",
                "csv-format" => true,
                data: [*_.fetch(:dns)].join(','),
              },
              _[:domain] && {
                name: "domain-name",
                code: 15,
                space: "dhcp4",
                "csv-format" => true,
                data: _.fetch(:domain),
              },
              _[:syslog] && {
                name: "log-servers",
                space: "dhcp4",
                "csv-format" => true,
                data: _.fetch(:syslog),
              },
            ].compact,
            reservations: [*_[:reservations]].map do |r|
              {
                "hw-address" => r.fetch(:mac).downcase,
                "ip-address" => r.fetch(:ip),
              }.tap do |rd|
                rd["hostname"] = (_[:domain] ? "#{r[:name]}.#{_[:domain]}" : r[:name]) if r[:name]
              end
            end
          }
        end
      ),
    ],
    "option-data" => [
      node[:kea][:dns] && {
        name: "domain-name-servers",
        code: 6,
        space: "dhcp4",
        "csv-format" => true,
        data: [*node[:kea].fetch(:dns)].join(','),
      },
    ].compact,
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

