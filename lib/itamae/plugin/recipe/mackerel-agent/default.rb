require "toml"

# set default attributes
node['mackerel-agent'] = {} unless node['mackerel-agent']
node['mackerel-agent']['conf'] = node['mackerel-agent'].fetch('conf', {})
node['mackerel-agent']['conf']['apikey'] = node['mackerel-agent']['conf'].fetch('apikey', nil)
node['mackerel-agent']['conf']['pidfile'] = node['mackerel-agent']['conf'].fetch('pidfile', "/var/run/mackerel-agent.pid")
node['mackerel-agent']['conf']['root'] = node['mackerel-agent']['conf'].fetch('root', "/var/lib/mackerel-agent")
node['mackerel-agent']['conf']['verbose'] = node['mackerel-agent']['conf'].fetch('verbose', false)
node['mackerel-agent']['start_on_setup'] = node['mackerel-agent'].fetch('start_on_setup', true)
node['mackerel-agent']['package-action'] = node['mackerel-agent'].fetch('package-action', :install)
node['mackerel-agent']['plugins'] = node['mackerel-agent'].fetch('plugins', [])

case node[:platform]
when "debian", "ubuntu"
  remote_file "/etc/apt/sources.list.d/mackerel.list"
  execute "import mackerel GPG key" do
    command "curl -fsS https://mackerel.io/assets/files/GPG-KEY-mackerel | apt-key add -"
  end
  execute "apt-get update -qq"
when "redhat", "fedora"
  execute "import mackerel GPG key" do
    command "rpm --import https://mackerel.io/assets/files/GPG-KEY-mackerel"
  end
  remote_file "/etc/yum.repos.d/mackerel.repo"
when "amazon"
  execute "import mackerel GPG key" do
    command "rpm --import https://mackerel.io/assets/files/GPG-KEY-mackerel"
  end
  remote_file "/etc/yum.repos.d/mackerel.repo" do
    source "./files/etc/yum.repos.d/mackerel-amznlinux.repo"
  end
else
  raise "not supported this platform: " + node[:platform]
end

package "mackerel-agent" do
  action node['mackerel-agent']['package-action'].to_sym
  if node['mackerel-agent']['start_on_setup']
    notifies :restart, "service[mackerel-agent]"
  end
end

node['mackerel-agent']['plugins'].each do |plugin|
  package plugin do
    action :install
  end
end

file "/etc/mackerel-agent/mackerel-agent.conf" do
  owner "root"
  group "root"
  content TOML::Generator.new(node['mackerel-agent']['conf']).body
  if node['mackerel-agent']['start_on_setup']
    notifies :restart, "service[mackerel-agent]"
  end
end

service "mackerel-agent" do
  if node['mackerel-agent']['start_on_setup']
    action [:enable, :start]
  else
    action :enable
  end
end
