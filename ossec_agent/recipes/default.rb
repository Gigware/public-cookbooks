case node['os']
when "linux"
  install_cmds = value_for_platform(
    ["ubuntu"] => {
	  "12.04" => ["apt-key adv --fetch-keys http://ossec.wazuh.com/repos/apt/conf/ossec-key.gpg.key", "echo 'deb http://ossec.wazuh.com/repos/apt/ubuntu precise main' >> /etc/apt/sources.list", "apt-get update"],
	  "14.04" => ["apt-key adv --fetch-keys http://ossec.wazuh.com/repos/apt/conf/ossec-key.gpg.key", "echo 'deb http://ossec.wazuh.com/repos/apt/ubuntu trusty main' >> /etc/apt/sources.list", "apt-get update"],
	  "14.10" => ["apt-key adv --fetch-keys http://ossec.wazuh.com/repos/apt/conf/ossec-key.gpg.key", "echo 'deb http://ossec.wazuh.com/repos/apt/ubuntu utopic main' >> /etc/apt/sources.list", "apt-get update"],
      "default" => ["apt-key adv --fetch-keys http://ossec.wazuh.com/repos/apt/conf/ossec-key.gpg.key", "echo 'deb http://ossec.wazuh.com/repos/apt/ubuntu precise main' >> /etc/apt/sources.list", "apt-get update"]
    },
    ["debian"] => {
	  "8.0" => ["apt-key adv --fetch-keys http://ossec.wazuh.com/repos/apt/conf/ossec-key.gpg.key", "echo 'deb http://ossec.wazuh.com/repos/apt/debian jessie main' >> /etc/apt/sources.list", "apt-get update"],
	  "7.0" => ["apt-key adv --fetch-keys http://ossec.wazuh.com/repos/apt/conf/ossec-key.gpg.key", "echo 'deb http://ossec.wazuh.com/repos/apt/debian wheezy main' >> /etc/apt/sources.list", "apt-get update"],
	  "6.0" => ["apt-key adv --fetch-keys http://ossec.wazuh.com/repos/apt/conf/ossec-key.gpg.key", "echo 'deb http://ossec.wazuh.com/repos/apt/debian sid main' >> /etc/apt/sources.list", "apt-get update"],
      "default" => ["apt-key adv --fetch-keys http://ossec.wazuh.com/repos/apt/conf/ossec-key.gpg.key", "echo 'deb http://ossec.wazuh.com/repos/apt/debian wheezy main' >> /etc/apt/sources.list", "apt-get update"]
    },
    ["centos", "redhat", "fedora", "amazon"] => {
      "default" => ["wget -q -O - https://www.atomicorp.com/installers/atomic | sh"]
    }
  )
  install_packs = value_for_platform(
   ["ubuntu", "debian"] => {"default" => ["ossec-hids-agent"]},
   ["centos", "redhat", "fedora", "amazon"] => {"default" => ["ossec-hids-client"]}
  )  
  servicesarr = value_for_platform(
   ["ubuntu", "debian"] => {"default" => ["ossec"]},
   ["centos", "redhat", "fedora", "amazon"] => {"default" => ["ossec-hids"]}
  )
 
 install_cmds.each do |command|
  execute "#{command}" do
   not_if { ::File.exists?("/var/ossec/etc/ossec.conf")}
  end
 end
 
 install_packs.each do |pkg|
  package pkg do
   action :install
  end
 end

 end
 
#Get databag items set as JSON in berkshelf
data_bag_vars = data_bag_item("ossec", "user")

#Get instance ID and set the API full path URL
agent_name=data_bag_vars['agent_name']

ossec_server = Array.new

if node.run_list.roles.include?(node['ossec']['server_role'])
  ossec_server << node['ipaddress']
end

node.set['ossec']['user']['install_type'] = "agent"
node.set['ossec']['user']['agent_server_ip'] = data_bag_vars['agent_server_ip']

node.save unless Chef::Config[:solo]

user "ossecd" do
  comment "OSSEC Distributor"
  shell "/bin/bash"
  system true
  gid "ossec"
  home node['ossec']['user']['dir']
end

directory "#{node['ossec']['user']['dir']}/.ssh" do
  owner "ossecd"
  group "ossec"
  mode 0750
end
 
#template "#{node['ossec']['user']['dir']}/bin/ossec-batch-manager.pl" do
#  source "#{Chef::Config[:file_cache_path]}/#{ossec_dir}/contrib/ossec-batch-manager.pl"
#  local true
#  owner "root"
#  group "ossec"
#  mode 0755
#end

template "#{node['ossec']['user']['dir']}/etc/ossec.conf" do
  source "ossec.conf.erb"
  owner "root"
  group "ossec"
  mode 0440
  variables(:ossec => node['ossec']['user'])
  #notifies :restart, "service[ossec]"
end

case node['platform']
when "arch"
  template "/etc/rc.d/ossec" do
    source "ossec.rc.erb"
    owner "root"
    mode 0755
  end
end

service "#{servicesarr[0]}" do
  supports :status => true, :start => true, :stop => true, :restart => true
  action :enable
end

if node['platform'] == "debian"
 execute "Create agent key using /var/ossec/bin/agent-auth -m #{data_bag_vars['agent_server_ip']} -A #{agent_name} && /etc/init.d/ossec restart" do
  command "/var/ossec/bin/agent-auth -m #{data_bag_vars['agent_server_ip']} -A #{agent_name}"
  not_if "grep #{agent_name} /var/ossec/etc/client.keys 2>/dev/null"
  action :run
 end
else
 execute "Create agent key using /var/ossec/bin/agent-auth -m #{data_bag_vars['agent_server_ip']} -A #{agent_name}" do
  command "/var/ossec/bin/agent-auth -m #{data_bag_vars['agent_server_ip']} -A #{agent_name}"
  not_if "grep #{agent_name} /var/ossec/etc/client.keys 2>/dev/null"
  notifies :restart, "service[#{servicesarr[0]}]"
  action :run
 end
end
