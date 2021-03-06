#!/bin/sh

SERVER=$1
HOSTNAME=$2

[ "$SERVER" = "" ] && echo "Usage: $0 ServerName AgentName" && exit 1
[ "$HOSTNAME" = "" ] && { 
 echo "Using instance ID if present or actual hostname if not as agent name"
 HOSTNAME=`wget -qO- http://169.254.169.254/latest/meta-data/instance-id`
 [ "$HOSTNAME" = "" ] && HOSTNAME=`hostname`
}

[ -f /usr/bin/aptitude ] && aptitude update && aptitude -y install git libssl-dev wget curl
[ -f /usr/bin/apt-get ] && apt-get update && apt-get -y install git libssl-dev wget curl
[ -f /usr/bin/yum ] && yum -y install git openssl-devel wget

[ ! -f /usr/bin/chef-solo ] && curl -LO https://www.chef.io/chef/install.sh && sudo bash ./install.sh -v 11.18.6 && rm install.sh

mkdir -p /var/chef/data_bags/ossec

echo "{ 
  \"recipes\": [ \"ossec_agent\" ]
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
