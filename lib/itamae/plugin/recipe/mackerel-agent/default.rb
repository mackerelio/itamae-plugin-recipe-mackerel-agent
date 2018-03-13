require "toml"

# set default attributes
node['mackerel-agent'] = {} unless node['mackerel-agent']
node['mackerel-agent']['conf'] = node['mackerel-agent'].fetch('conf', {})
node['mackerel-agent']['start_on_setup'] = node['mackerel-agent'].fetch('start_on_setup', true)
node['mackerel-agent']['package-action'] = node['mackerel-agent'].fetch('package-action', :install)
node['mackerel-agent']['plugins'] = node['mackerel-agent'].fetch('plugins', [])

def platform_version_satisfy?(op)
  Gem::Requirement.create(op).satisfied_by?(Gem::Version.create(node[:platform_version]))
end

case node[:platform]
when "debian", "ubuntu"
  if node[:platform] == "debian" and platform_version_satisfy?('>= 8') or node[:platform] == "ubuntu" and platform_version_satisfy?('>= 16.04')
    execute "import mackerel GPG key v2" do
      command "curl -fsSL https://mackerel.io/file/cert/GPG-KEY-mackerel-v2 | apt-key add -"
    end
    remote_file "/etc/apt/sources.list.d/mackerel.list" do
      source "./files/etc/apt/sources.list.d/mackerel-v2.list"
    end
  else
    execute "import mackerel GPG key" do
      command "curl -fsSL https://mackerel.io/file/cert/GPG-KEY-mackerel | apt-key add -"
    end
    remote_file "/etc/apt/sources.list.d/mackerel.list"
  end
  execute "apt-get update -qq"
when "redhat", "fedora"
  if node[:platform] == "redhat" and platform_version_satisfy?('>= 7')
    execute "import mackerel GPG key v2" do
      command "rpm --import https://mackerel.io/file/cert/GPG-KEY-mackerel-v2"
    end
    remote_file "/etc/yum.repos.d/mackerel.repo" do
      source "./files/etc/yum.repos.d/mackerel-v2.repo"
    end
  else
    execute "import mackerel GPG key" do
      command "rpm --import https://mackerel.io/file/cert/GPG-KEY-mackerel"
    end
    remote_file "/etc/yum.repos.d/mackerel.repo"
  end
when "amazon"
  if platform_version_satisfy?('~> 2.0')
    execute "import mackerel GPG key v2" do
      command "rpm --import https://mackerel.io/file/cert/GPG-KEY-mackerel-v2"
    end
    remote_file "/etc/yum.repos.d/mackerel.repo" do
      source "./files/etc/yum.repos.d/mackerel-amznlinux-v2.repo"
    end
  else
    execute "import mackerel GPG key" do
      command "rpm --import https://mackerel.io/file/cert/GPG-KEY-mackerel"
    end
    remote_file "/etc/yum.repos.d/mackerel.repo" do
      source "./files/etc/yum.repos.d/mackerel-amznlinux.repo"
    end
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

node.validate! do
  {
    'mackerel-agent': {
      'conf':{
        'apikey': string,
      }
    }
  }
end
