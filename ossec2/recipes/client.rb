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
agent_name=""
uri = URI('http://169.254.169.254/latest/meta-data/instance-id')
response = Net::HTTP.get(uri)
if data_bag_vars['api_endpoint'] != nil
 @api_uri="#{data_bag_vars['api_endpoint']}/#{response.gsub(/\n/,'')}?field=hidsAgentKey__c&field=hidsStatus__c&field=hidsAssignedAgentName__c&field=instanceId__c&field=hidsagentname__c&field=idsagentid__c"
else
 if data_bag_vars['agent_name'] != nil
  agent_name=data_bag_vars['agent_name']
 else
  agent_name=response.gsub(/\n/,'')
 end
end

#Get client key file contents
client_key=nil
if data_bag_vars['api_endpoint'] != nil
 uri = URI.parse(@api_uri)
 http = Net::HTTP.new(uri.host, uri.port)
 http.use_ssl = true
 http.verify_mode = OpenSSL::SSL::VERIFY_NONE
 response = http.get(uri.request_uri,{"Accept" => "application/json", "Authorization" => data_bag_vars['auth_token']})
 client_data=JSON.parse(response.body)["attributes"]
 client_key="#{client_data["idsagentid__c"]} #{client_data["hidsagentname__c"]} any #{client_data["hidsagentkey__c"]}"
end

ossec_server = Array.new

if node.run_list.roles.include?(node['ossec']['server_role'])
  ossec_server << node['ipaddress']
else
  search(:node,"role:#{node['ossec']['server_role']}") do |n|
    ossec_server << n['ipaddress']
  end
end

node.set['ossec']['user']['install_type'] = "agent"
node.set['ossec']['user']['agent_server_ip'] = data_bag_vars['agent_server_ip']

node.save

include_recipe "ossec"

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
  notifies :restart, "service[ossec]"
  action :run
 end
end
