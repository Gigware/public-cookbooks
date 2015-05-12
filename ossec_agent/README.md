1. Download script https://github.com/Gigware/public-cookbooks/blob/master/ossec_agent.sh to your server like to /root/ossec_agent.sh. You can do this by running:


    cd /root && wget https://raw.githubusercontent.com/Gigware/public-cookbooks/master/ossec_agent.sh 

2. Run the script using:

    chmod +x /root/ossec_agent.sh && /root/ossec_agent.sh SERVER_NAME AGENT_NAME


where SERVER_NAME is the name of the actual server and AGENT_NAME of the agent. If no AGENT_NAME specified, the instance ID will be used as agent name, otherwise the hostname.

NOTE: CentOs5/Rhel5 platform may be missing EL5 'git' in the official repos, you can install it from the EPEL repository:
      rpm -Uvh http://dl.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm
