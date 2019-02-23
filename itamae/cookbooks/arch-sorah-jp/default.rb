remote_file '/etc/17C611F16D92677398E0ADF51AD43CA09D82C624.pem' do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'execute[import 17C611F16D92677398E0ADF51AD43CA09D82C624.pem]'
end

execute 'import 17C611F16D92677398E0ADF51AD43CA09D82C624.pem' do
  command 'pacman-key -d 17C611F16D92677398E0ADF51AD43CA09D82C624; pacman-key -a /etc/17C611F16D92677398E0ADF51AD43CA09D82C624.pem && pacman-key --lsign-key 17C611F16D92677398E0ADF51AD43CA09D82C624'
  not_if 'pacman-key -l 17C611F16D92677398E0ADF51AD43CA09D82C624 | grep "^uid.* full "'
  notifies :run, 'execute[pacman -Sy]'
end

file '/etc/pacman.conf' do
  action :edit
  server = "[aur-sorah]\nSigLevel = Required\nServer = https://arch.sorah.jp/$repo/os/$arch"

  block do |content|
    if content =~ /^\[aur-sorah\]/
      content.gsub!(/^\[aur-sorah\].*\n.*\n.*$/, server)
    else
      content << server << "\n"
    end
  end
end
