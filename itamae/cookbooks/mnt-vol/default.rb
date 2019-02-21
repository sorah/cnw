node.reverse_merge!(
  mnt_vol: {
    device: node[:extra_disk],
    fstype: 'ext4',
  }
)

directory '/mnt/vol' do
  owner 'root'
  group 'root'
  mode  '0755'
end

execute 'mkfs /mnt/vol' do
  command "mkfs.#{node[:mnt_vol].fetch(:fstype)} #{node[:mnt_vol].fetch(:device)}"
  not_if "grep '^#{node[:mnt_vol].fetch(:device)}' /etc/fstab"
end

fstab node[:mnt_vol].fetch(:device) do
  mountpoint '/mnt/vol'
  fstype node[:mnt_vol].fetch(:fstype)
  options 'rw,defaults'
  dump 1
  fsckorder 1
end

execute 'mount /mnt/vol' do
  not_if "grep -q /mnt/vol /proc/mounts"
end
