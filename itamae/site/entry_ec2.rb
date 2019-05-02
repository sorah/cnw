node[:desired_hostname] = node.dig(:hocho_ec2, :tags, :Name)
node[:self_router] = node.fetch(:hocho_subnet).fetch(:cidr_block).sub(%r{\.(\d+)/\d+$}) { ".#{$1.to_i.succ.to_s}" }
