1. Install this cookbook on your chef server using ```knife cookbook install ossec_agent_server``` after putting it into the /var/chef/cookbooks directory.


2. Create a role named ossec_agent containing this cookbook, this can be done easily using the chef web interface under the roles section(Under Policy -> Roles push Create and assign the cookbook)

    cd /root && wget --no-check-certificate https://raw.githubusercontent.com/Gigware/public-cookbooks/master/ossec_agent.sh

2. Run the script using:

    chmod +x /root/ossec_agent.sh && /root/ossec_agent.sh SERVER_NAME AGENT_NAME


where SERVER_NAME is the name of the actual server and AGENT_NAME of the agent. If no AGENT_NAME specified, the instance ID will be used as agent name, otherwise the hostname.

NOTE: CentOs5/Rhel5 platform may be missing EL5 'git' in the official repos, you should run the next command prior to taking steps 1 and 2:

    rpm -Uvh http://dl.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm
