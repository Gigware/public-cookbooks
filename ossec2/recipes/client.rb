#
# Cookbook Name:: ossec
# Recipe:: client
#
# Copyright 2010, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'net/http'
require 'json'

#Get databag items set as JSON in berkshelf
data_bag_vars = data_bag_item("ossec", "user")

#Get instance ID and set the API full path URL
agent_name=data_bag_vars['agent_name']

#Get client key file contents
client_key=nil

ossec_server = Array.new

if node.run_list.roles.include?(node['ossec']['server_role'])
  ossec_server << node['ipaddress']
#else
#  search(:node,"role:#{node['ossec']['server_role']}") do |n|
#    ossec_server << n['ipaddress']
#  end
end

node.set['ossec']['user']['install_type'] = "agent"
node.set['ossec']['user']['agent_server_ip'] = data_bag_vars['agent_server_ip']

node.save unless Chef::Config[:solo]

include_recipe "ossec2"

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

#template "#{node['ossec']['user']['dir']}/.ssh/authorized_keys" do
#  source "ssh_key.erb"
#  owner "ossecd"
#  group "ossec"
#  mode 0600
#  variables(:key => "test")
#end

#Create the service
template "/etc/init.d/ossec" do
  source "ossec_init.erb"
  owner "root"
  group "root"
  mode 0755
end
execute "Setup the service" do
 command "ln -s /etc/init.d/ossec /etc/rc0.d/K20ossec && ln -s /etc/init.d/ossec /etc/rc1.d/K20ossec && ln -s /etc/init.d/ossec /etc/rc2.d/K20ossec && ln -s /etc/init.d/ossec /etc/rc3.d/K20ossec && ln -s /etc/init.d/ossec /etc/rc4.d/K20ossec && ln -s /etc/init.d/ossec /etc/rc5.d/K20ossec && ln -s /etc/init.d/ossec /etc/rc6.d/K20ossec"
 not_if 'test -f /etc/rc0.d/K20ossec'
 action :run
end

service "ossec" do
  supports :status => true, :start => true, :stop => true, :restart => true
  action :enable
end

if client_key!=nil
 file "#{node['ossec']['user']['dir']}/etc/client.keys" do
   owner "ossecd"
   group "ossec"
   mode 0660
   content client_key
   notifies :restart, "service[ossec]"
 end
else
 execute "Create agent key using /var/ossec/bin/agent-auth -m #{data_bag_vars['agent_server_ip']} -A #{agent_name}" do
  command "/var/ossec/bin/agent-auth -m #{data_bag_vars['agent_server_ip']} -A #{agent_name}"
  not_if "grep #{agent_name} /var/ossec/etc/client.keys 2>/dev/null"
  notifies :restart, "service[ossec]"
  action :run
 end
end
