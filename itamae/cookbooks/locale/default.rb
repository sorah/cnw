node.reverse_merge!(
  locale_gen: {
    locale: 'en_US.UTF-8',
    gen: ['en_US UTF-8'],
  },
)

execute 'locale-gen' do
  action :nothing
end

file '/etc/locale.gen' do
  content "#{node[:locale_gen][:gen].join(?\n)}\n"
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[locale-gen]'
end

file '/etc/locale.conf' do
  content "LANG=#{node[:locale_gen][:locale]}\n"
  owner 'root'
  group 'root'
  mode  '0644'
end
