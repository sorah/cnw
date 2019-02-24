service 'systemd-resolved' do
  action :enable
end

include_cookbook 'systemd-resolved::disable-stub-resolver'
