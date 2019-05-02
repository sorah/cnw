node[:roles] = (node.dig(:hocho_ec2, :tags, :Role) || 'base').split(',')
node[:roles].each do |_|
  include_role _
end
