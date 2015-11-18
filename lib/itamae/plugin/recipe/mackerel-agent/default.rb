case node[:platform]
when "debian", "ubuntu"
  remote_file "/etc/apt/sources.list.d/mackerel.list"
  execute "import mackerel GPG key" do
    command "curl -fsS https://mackerel.io/assets/files/GPG-KEY-mackerel | apt-key add -"
  end
  execute "apt-get update -qq"
when "redhat", "fedra"
  execute "import mackerel GPG key" do
    command "rpm --import https://mackerel.io/assets/files/GPG-KEY-mackerel"
  end
  remote_file "/etc/yum.repos.d/mackerel.repo"
else
  raise "not supported this platform: " + node[:platform]
end

template "/etc/mackerel-agent/mackerel-agent.conf"
package "mackerel-agent"

service "mackerel-agent" do
  action [:enable, :start]
end
