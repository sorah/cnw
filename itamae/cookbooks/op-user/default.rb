node.reverse_merge!(
  op_user: {
    name: node.fetch(:op_user_name),
    uid: 1000,
    authorized_keys: [],
    include_default_authorized_keys: true,
  },
)

username = node[:op_user].fetch(:name)

group username do
  gid node[:op_user][:uid]
end

user username do
  uid node[:op_user][:uid]
  gid node[:op_user][:uid]
  home "/home/#{username}"
end

directory "/home/#{username}" do
  owner username
  group username
  mode "755"
end

directory "/home/#{username}/.ssh" do
  owner username
  group username
  mode "0700"
end

file "/home/#{username}/.ssh/authorized_keys" do
  authorized_keys = node[:op_user][:authorized_keys]
  if node[:op_user][:include_default_authorized_keys]
    authorized_keys.concat node[:default_authorized_keys]
  end

  content authorized_keys.join(?\n) + ?\n
  owner username
  group username
  mode "600"
end

file '/etc/sudoers.d/opuser' do
  content "#{username} ALL=(ALL) NOPASSWD:ALL\n"
  owner 'root'
  group 'root'
  mode '440'
end
