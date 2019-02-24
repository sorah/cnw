node.reverse_merge!(
  prometheus: {
    cloudwatch_exporter: {
      configs: {
        'us-east-1' => {
          port: 19106,
          config: {
            region: 'us-east-1',
            metrics: [
              [{}].flat_map do |stats_opt|
                %w(
                  4xxErrorRate
                  5xxErrorRate
                  BytesDownloaded
                  BytesUploaded
                  Requests
                  TotalErrorRate
                ).map do |metric|
                  { aws_namespace: 'AWS/CloudFront', aws_dimensions: %w(DistributionId Region), aws_metric_name: metric, period_seconds: 300 }.merge(stats_opt)
                end
              end,
            ].flatten.map{ |_| _[:aws_dimensions] ? _.merge(aws_dimension_select_regex: _[:aws_dimensions].map{ |k| [k, ['.*']] }.to_h) : _},
          },
        },
        'ap-northeast-1h' => {
          port: 29106,
          config: {
            region: 'ap-northeast-1',
            period_seconds: 60,
            delay_seconds: 120,
            metrics: [
              [{aws_dimensions: %w(LoadBalancer AvailabilityZone TargetGroup)}].flat_map do |dim_opt|
                [
                  [{aws_statistics: %w(Average Minimum Maximum)}, {aws_extended_statistics: %w(p50 p95 p99)}].flat_map do |stats_opt|
                    %w(
                      TargetResponseTime
                    ).map do |metric|
                      {
                        aws_namespace: 'AWS/ApplicationELB',
                        aws_metric_name: metric,
                      }.merge(stats_opt).merge(dim_opt)
                    end
                  end,
                  %w(
                    RequestCount
                    NewConnectionCount
                    HTTPCode_Target_5XX_Count
                    HTTPCode_Target_4XX_Count
                    HTTPCode_Target_3XX_Count
                    HTTPCode_Target_2XX_Count
                    HTTPCode_ELB_5XX_Count
                    HTTPCode_ELB_4XX_Count
                  ).map do |metric|
                    {
                      aws_namespace: 'AWS/ApplicationELB',
                      aws_metric_name: metric,
                      aws_statistics: %w(Sum)
                    }.merge(dim_opt)
                  end,
                ]
              end,

              [{aws_statistics: %w(SampleCount Average Minimum Maximum)}].flat_map do |stats_opt|
                %w(
                  MemoryUtilization
                  CPUUtilization
                ).map do |metric|
                  {
                    aws_namespace: 'AWS/ECS',
                    aws_metric_name: metric,
                    aws_dimensions: %w(ClusterName ServiceName),
                  }.merge(stats_opt)
                end
              end,
            ].flatten,
          },
        },
        'ap-northeast-1' => {
          port: 9106,
          config: {
            region: 'ap-northeast-1',
            delay_seconds: 360,
            metrics: [
              [{aws_statistics: %w(Average Minimum Maximum)}, {aws_extended_statistics: %w(p50 p95 p99)}].flat_map do |stats_opt|
                %w(
                  Latency
                ).map do |metric|
                  {
                    aws_namespace: 'AWS/ELB',
                    aws_metric_name: metric,
                    aws_dimensions: %w(LoadBalancerName),
                    period_seconds: 300
                  }.merge(stats_opt)
                end
              end,
              %w(
                HTTPCode_Backend_5XX
                HTTPCode_Backend_4XX
                HTTPCode_Backend_3XX
                HTTPCode_Backend_2XX
                HTTPCode_ELB_5XX
                HTTPCode_ELB_4XX
              ).map do |metric|
                {
                  aws_namespace: 'AWS/ELB',
                  aws_metric_name: metric,
                  aws_dimensions: %w(LoadBalancerName),
                  period_seconds: 300,
                  aws_statistics: %w(Sum)
                }
              end,

              [{aws_statistics: %w(Average Minimum Maximum)}].flat_map do |stats_opt|
                %w(
                  VolumeReadBytes
                  VolumeIdleTime
                  VolumeReadOps
                  BurstBalance
                  VolumeQueueLength
                  VolumeWriteBytes
                  VolumeWriteOps
                  VolumeTotalReadTime
                  VolumeTotalWriteTime
                ).map do |metric|
                  {
                    aws_namespace: 'AWS/EBS',
                    aws_metric_name: metric,
                    aws_dimensions: %w(VolumeId),
                    period_seconds: 300
                  }.merge(stats_opt)
                end
              end,

              [{aws_statistics: %w(Average Minimum Maximum)}].flat_map do |stats_opt|
                %w(
                  CPUCreditBalance
                  CPUCreditUsage
                  CPUSurplusCreditBalance
                  CPUSurplusCreditsCharged
                  CPUUtilization
                  DiskReadOps
                  DiskWriteOps
                  NetworkIn
                  NetworkOut
                  NetworkPacketsIn
                  NetworkPacketsOut
                  StatusCheckFailed
                  StatusCheckFailed_Instance
                ).map do |metric|
                  {
                    aws_namespace: 'AWS/EC2',
                    aws_metric_name: metric,
                    aws_dimensions: %w(InstanceId),
                    period_seconds: 300
                  }.merge(stats_opt)
                end
              end,

              [{aws_statistics: %w(Sum Average)}].flat_map do |stats_opt|
                %w(
                  NewConnections
                  CacheMisses
                  Reclaimed
                  Evictions
                ).map do |metric|
                  {
                    aws_namespace: 'AWS/ElastiCache',
                    aws_metric_name: metric,
                    aws_dimensions: %w(CacheClusterId CacheNodeId),
                    period_seconds: 300
                  }.merge(stats_opt)
                end
              end,
              [{aws_statistics: %w(Average Minimum Maximum)}].flat_map do |stats_opt|
                %w(
                  ReplicationLag
                  CurrConnections
                  CPUUtilization
                  CurrItems
                  FreeableMemory
                ).map do |metric|
                  {
                    aws_namespace: 'AWS/ElastiCache',
                    aws_metric_name: metric,
                    aws_dimensions: %w(CacheClusterId CacheNodeId),
                    period_seconds: 300
                  }.merge(stats_opt)
                end
              end,

              [{aws_statistics: %w(Sum Average)}].flat_map do |stats_opt|
                %w(
                  Errors
                  Invocations
                  Throttles
                ).map do |metric|
                  {
                    aws_namespace: 'AWS/Lambda',
                    aws_metric_name: metric,
                    aws_dimensions: %w(FunctionName Resource),
                    period_seconds: 300
                  }.merge(stats_opt)
                end
              end,
              [{aws_statistics: %w(Average Minimum Maximum)}].flat_map do |stats_opt|
                %w(
                  ConcurrentExecutions
                  UnreservedConcurrentExecutions
                ).map do |metric|
                  {
                    aws_namespace: 'AWS/Lambda',
                    aws_metric_name: metric,
                    aws_dimensions: %w(FunctionName Resource),
                    period_seconds: 300
                  }.merge(stats_opt)
                end
              end,

              [{aws_statistics: %w(Sum Average Minimum Maximum)}].flat_map do |stats_opt|
                %w(
                  ConnectionAttemptCount
                  IdleTimeoutCount
                  BytesInFromDestination
                  PacketsDropCount
                  ConnectionEstablishedCount
                  ErrorPortAllocation
                  BytesOutToSource
                  BytesInFromSource
                  BytesOutToDestination
                  ActiveConnectionCount
                ).map do |metric|
                  {
                    aws_namespace: 'AWS/NATGateway',
                    aws_metric_name: metric,
                    aws_dimensions: %w(NatGatewayId),
                    period_seconds: 300
                  }.merge(stats_opt)
                end
              end,

              [{aws_statistics: %w(Sum Average Minimum Maximum)}].flat_map do |stats_opt|
                %w(
                  CPUCreditBalance
                  CPUCreditUsage
                  CPUUtilization
                  DatabaseConnections
                  DBLoad
                  DBLoadCPU
                  DBLoadNonCPU
                  Deadlocks
                  DiskQueueDepth
                  EngineUptime
                  FreeableMemory
                  FreeLocalStorage
                  FreeStorageSpace
                  NetworkReceiveThroughput
                  NetworkThroughput
                  NetworkTransmitThroughput
                  OldestReplicationSlotLag
                  RDSToAuroraPostgreSQLReplicaLag
                  ReadIOPS
                  ReadLatency
                  ReadThroughput
                  ReplicationSlotDiskUsage
                  SwapUsage
                  TransactionLogsDiskUsage
                  TransactionLogsGeneration
                  WriteIOPS
                  WriteLatency
                  WriteThroughput
                 ).map do |metric|
                  {
                    aws_namespace: 'AWS/RDS',
                    aws_metric_name: metric,
                    aws_dimensions: %w(DBInstanceIdentifier),
                    period_seconds: 300
                  }.merge(stats_opt)
                end
              end,

              [{aws_statistics: %w(Average Maximum)}].flat_map do |stats_opt|
                %w(
                  NumberOfObjects
                  BucketSizeBytes
                 ).map do |metric|
                  {
                    aws_namespace: 'AWS/S3',
                    aws_metric_name: metric,
                    aws_dimensions: %w(BucketName),
                    period_seconds: 86400,
                    set_timestamp: false
                  }.merge(stats_opt)
                end
              end,

              [{aws_statistics: %w(Sum Average)}].flat_map do |stats_opt|
                %w(
                  NumberOfMessagesSent
                  NumberOfEmptyReceives
                  NumberOfMessagesDeleted
                  NumberOfMessagesReceived
                 ).map do |metric|
                  {
                    aws_namespace: 'AWS/SQS',
                    aws_metric_name: metric,
                    aws_dimensions: %w(QueueName),
                    period_seconds: 300
                  }.merge(stats_opt)
                end
              end,
              [{aws_statistics: %w(Average Minimum Maximum)}].flat_map do |stats_opt|
                %w(
                  SentMessageSize
                  ApproximateNumberOfMessagesVisible
                  ApproximateAgeOfOldestMessage
                  ApproximateNumberOfMessagesNotVisible
                  ApproximateNumberOfMessagesDelayed
                 ).map do |metric|
                  {
                    aws_namespace: 'AWS/SQS',
                    aws_metric_name: metric,
                    aws_dimensions: %w(QueueName),
                    period_seconds: 300
                  }.merge(stats_opt)
                end
              end,

              [{aws_statistics: %w(Sum Average Minimum Maximum)}].flat_map do |stats_opt|
                %w(
                  TunnelDataIn
                  TunnelState
                  TunnelDataOut
                ).map do |metric|
                  {
                    aws_namespace: 'AWS/VPN',
                    aws_metric_name: metric,
                    aws_dimensions: %w(TunnelIpAddress),
                    period_seconds: 300
                  }.merge(stats_opt)
                end
              end,
            ].flatten.map{ |_| _[:aws_dimensions] ? _.merge(aws_dimension_select_regex: _[:aws_dimensions].map{ |k| [k, ['.*']] }.to_h) : _},
          },
        },
      },
    },
  },
)

include_cookbook 'prometheus-cloudwatch-exporter'
