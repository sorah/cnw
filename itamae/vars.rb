node.reverse_merge!(
  ssh: {
    port: [22],
  },
)
node[:op_user_name] = 'cnw'
node[:orgname] = 'cnw'
node[:site_domain] = 'nw.test.invalid'
node[:site_rdomain] = '25.10.in-addr.arpa'
node[:site_cidr] = '10.25.0.0/16'
node[:site_admin_domain] = "s.#{node.fetch(:site_domain)}"
# node[:site_cidr6] = ''

node[:use_nftables] = true

node[:wlc_host] = "wlc-001.venue.l.#{node.fetch(:site_domain)}"
# node[:prometheus_host] =
node[:grafana_host] = node[:prometheus_host]
node[:syslog_host] = "syslog-001.cloud.l.#{node.fetch(:site_domain)}"

node[:snmp_community] = 'public'

node[:extra_disk] = "/dev/vdb"

node[:rproxy_htpasswd] = node[:secrets][:rproxy_htpasswd]
node[:default_authorized_keys] = [
  # sorah
  *"
    ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBADLFfXAbYvLbd3gTH08FfYEADFWVaa2xoHC4pzMNy+MoPbf9qPWTLGYlkXPL7QxgZH6dRk458rkfwEIySxajdIr0AEGcrvVTezzhYNvZReISWMBlO68cDprusADqLqoLus2booss4LIKmm6BI4vuuXtOOVhAdltj0gf/CVlpNuZ99szFw== americano2016ecdsa
    ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBACG1cKNR8SS4Dkm2wcia74RRmy9d7h62114MQd0H9zb1+1LxVa55Qqd8O232BH1i/fF/1o+eE3L5U7RCR8KUCuAXgFrF429BETaiiBnSErv5yrHJS5RTTjEhA1d9Ygk0o3Und6+90waBXAk2oPVP+OBNtYq1CraZQsXuqvlUtMrBnSTsQ== sorah-mulberry-ecdsa
    ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAF6LlpYSW3SrzjQcZYifI0JYJlUpj5myp/20h7/HxL8aImwU9pBSPch9NH2QL8RB/G5MlaZ1P52Kg4bVueJCwVoPABIEDx/u1ilSS+03UJW6Yfh3a7VT/iuudlFyUPY2x9M4Cf/JgXCaCV7Yb/f4JaCjulGXKbzzHx58EIcqNxbp64Jug== sorah-w1-my-ecdsa
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDnY8uGqMVviIttNHiz1M5MV5jL3GSt3nGWPxEErmEbaORQabn1UvBennzi87E4ZXa6wT9ZcfmvcrcckW6xiopU0A8CJSQAvKtpOB4eSFJkblELrmUpmxuDo5pHLpunpHHay2or8yPaLnwSfBnuyA7Lq2Cj1pw0LKq88Lda76ihWPWb7DfBVzedVYPKKunIk/4Wwj120ILOcoYI0r0XWiaxx9d3IvNvXroR7qqiKKZMacBpUWCwT3iX6GB0jhSRIJ1Do9qDyp/Sx4wyj4SxXasni5pqg/8ARwCkiMrbkAaedRRvP4umxuhBRc4VzqeWTvj5dPlkguwt1avbg3g/IDuO7/iJSEASN2H7qJEhH5rL5Aq1HCkOHGdlibdsFLNiCoOGKMNRO4mPsAkyf4i/kURP+a50+lRVlQSGGzFR5FFFcR0P83E+BkS/UkxC9MVGkvidLSmto/UkGqCfdLP6RJQMH6W54KMQ1epjWiLvW9FkspRha73lfxh7pC+jACRmL0E= sorah-w2-my
    ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAHoLUkgSzQfIXMx7nS9TzgFubVwYBiaWYPh2Ges30IMytU8oQyrQ4V/mPjvWHrij9pz0Uz+tbhR1+Tza85LzyFiCwDrZDQNqLGB7b/bwhy9cGQPVGUdiObJ4f2MEPYzyueEtmCQuh1NiPl/p8HSIyEBOmc19duWfKyvDRvayg8hJAs4mg== sorah-wD-my-ecdsa
  ".lines.map(&:strip).reject(&:empty?),
]

host_lines = <<EOF
mgmt	10.25.128.0/24	10.25.128.254	rt-001	ens4	
lan	10.25.0.0/19	10.25.11.1	ap-hal-01		de:ad:be:ef:88:88
EOF

node[:hosts_data] = host_lines.lines.
  map { |l| dc, network, cidr, ip, name, iface, mac = l.chomp.split(?\t, 7);{dc: dc, network: network, cidr: cidr, ip: ip, name: name, mac: (mac && !mac.empty? && mac != '#N/A') ? mac : nil, iface: (iface && !iface.empty?) ? iface : nil} }.
  reject { |_| _[:ip].nil? || _[:ip].empty? }.
  group_by { |_| [_[:dc], _[:name]] }.
  map { |_, ips| [ips[0].merge(primary: true), ips[1..-1]].flatten }.
  flatten

node[:network_tester] ||= [
  {host: '8.8.8.8'},
  {host: '1.1.1.1'},
]

node.reverse_merge!(
  prometheus: {
    alertmanager: {
      # slack_url: 
    },
    snmp_hosts: [
      *node.fetch(:hosts_data).select{ |_| _[:primary] }.map { |_| ["#{_.fetch(:name)}.c.#{node[:site_domain]}", %w(if_mib)] }.reject { |_| _[0].include?('dxvif') },
      [node[:wlc_host], %w(cisco_wlc)],
    ],
  },
  kea: {
    # dns: 
    subnets: {
      # nanika: {
      #   id: 1,
      #   subnet: '10.0.0.0/16',
      #   pools: %w(10.0.0.0-10.0.255.255),
      #   router:
      #   domain:
      #   reservations: {
      #     hogehoge: {mac: '', ip: '',},
      #   },
      # },
    }
  }
)
