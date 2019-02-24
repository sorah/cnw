node.reverse_merge!(
  prometheus: {
    #snmp_hosts: [
    #  { targets: %w(host), labels: {__param_module: 'if_mib_ifname'} },
    #  { targets: %w(host), labels: {__param_module: 'cisco_wlc'} },
    #},
    rule_files: %w(
      aws_ec2
      aws_elb
      aws_lambda
      aws_nat
      aws_rds
      aws_sqs
      cloudwatch
      haproxy
      node
      prometheus
    ),
    config: {
      global: {
        scrape_interval: '20s',
        scrape_timeout: '10s',
        evaluation_interval: '20s',
        external_labels: {
        },
      },
      rule_files: %w(/etc/prometheus/rules/*.yml),
      scrape_configs: [],
      alerting: {
        alert_relabel_configs: [],
        alertmanagers: [
          static_configs: [
            targets: %w(localhost:9093),
          ],
        ],
      },
    },
  },
)

include_role 'prometheus::config-rules'

directory '/etc/prometheus/files' do
  owner 'root'
  group 'root'
  mode  '0755'
end

scrape_configs = node[:prometheus][:config][:scrape_configs]

scrape_configs.push(
  job_name: :prometheus,
  static_configs: [
    targets: %w(
      localhost:9090
    ),
  ],
)
#scrape_configs.push(
#  job_name: :cloudwatch,
#  scrape_interval: '2m',
#  scrape_timeout: '2m',
#  static_configs: [
#    targets: %w(
#      localhost:9106
#      localhost:19106
#    ),
#    labels: {downalert: 'ignore'},
#  ],
#)
#scrape_configs.push(
#  job_name: :cloudwatch_h,
#  scrape_interval: '1m',
#  scrape_timeout: '1m',
#  static_configs: [
#    targets: %w(
#      localhost:29106
#    ),
#    labels: {downalert: 'ignore'},
#  ],
#)

if node[:prometheus][:snmp_hosts]
  scrape_configs.push(
    job_name: :snmp,
    metrics_path: "/snmp",
    scrape_timeout: '19s',
    static_configs: node[:prometheus][:snmp_hosts],
    relabel_configs: [
      {source_labels: %w(__address__), target_label: '__param_target'},
      {source_labels: %w(__param_target), target_label: 'instance'},
      {target_label: '__address__', replacement: '127.0.0.1:9116'},
    ],
  )
end


host_jobs = [
  {
    job_name: 'node',
    port: 9100,
  },
  {
    job_name: 'unbound',
    role: '^dns-cache$',
    port: 9099,
    metrics_path: '/unbound_exporter/metrics',
  },
  #{
  #  job_name: 'haproxy',
  #  role: 'cache-s3|rproxy-misc|rproxy-s3',
  #  port: 9099,
  #  metrics_path: '/haproxy_exporter/metrics',
  #},
  {
    job_name: 'kea',
    role: 'dhcp',
    port: 9099,
    metrics_path: '/kea_exporter/metrics',
  },
]

if node[:hocho_ec2]
  host_jobs.each do |job|
    scrape_configs.push(
      job_name: "ec2_#{job.fetch(:job_name)}",
      ec2_sd_configs: [
        {
          region: node.dig(:hocho_ec2, :placement, :availability_zone)[0..-2],
          filters: [
            {name: 'vpc-id', values: [node.dig(:hocho_ec2, :vpc_id)]},
          ],
          port: job.fetch(:port),
        },
      ],
      metrics_path: job.fetch(:metrics_path, '/metrics'),
      relabel_configs: [
        {
          source_labels: ["__meta_ec2_instance_state"],
          regex: "^running$",
          action: "keep",
        },
        job.key?(:role) ? {
          source_labels: ["__meta_ec2_tag_Role"],
          regex: job.fetch(:role),
          action: "keep",
        } : nil,
        {
          source_labels: ["__meta_ec2_tag_Name"],
          target_label: "instance",
        },
        {
          source_labels: ["__meta_ec2_tag_Role"],
          target_label: "role",
        },
        {
          source_labels: ["__meta_ec2_tag_Status"],
          target_label: "status",
        },
        {
          source_labels: ["__meta_ec2_instance_type"],
          target_label: "instance_type",
        },
        {
          source_labels: ["__meta_ec2_availability_zone"],
          target_label: "availability_zone",
        },
        {
          source_labels: ["__meta_ec2_vpc_id"],
          target_label: "vpc_id",
        },
        *job[:relabel_configs],
      ].compact,
    )
  end
end
