#!/bin/sh

SERVER=$1
HOSTNAME=$2

[ "$SERVER" = "" ] && echo "Usage: $0 ServerName AgentName(optional)" && exit 1

[ ! -f /usr/bin/chef-solo ] && curl -LO https://www.chef.io/chef/install.sh && sudo bash ./install.sh -v 11.18.6 && rm install.sh

[ -f /usr/bin/aptitude ] && aptitude -y install git
[ -f /usr/bin/yum ] && yum -y install git

mkdir -p /var/chef/data_bags/ossec

echo $SERVER

echo "{ 
  \"recipes\": [ \"ossec2::client\" ]
}" > /root/ossec_chef.json

[ "$HOSTNAME" = "" ] && echo "{
\"id\": \"user\",
\"agent_server_ip\": \"$SERVER\"
}" > /var/chef/data_bags/ossec/user.json
[ "$HOSTNAME" != "" ] && echo "{
\"id\": \"user\",
\"agent_server_ip\": \"$SERVER\",
\"agent_name\": \"$HOSTNAME\"
}" > /var/chef/data_bags/ossec/user.json

echo "log_level          :info
log_location       STDOUT
file_cache_path    '/var/chef/cookbooks'
data_bag_path	   '/var/chef/data_bags'
cookbook_path      \"/root/public-cookbooks\"
Mixlib::Log::Formatter.show_time = false" > /root/solo.rb

cd /root && git clone https://github.com/Gigware/public-cookbooks
chef-solo -c /root/solo.rb -j /root/ossec_chef.json
rm -fr /root/solo.rb /root/public-cookbooks /root/ossec_chef.json /var/chef/data_bags/ossec/user.json
