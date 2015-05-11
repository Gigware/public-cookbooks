1. Download script https://github.com/Gigware/public-cookbooks/blob/master/ossec_agent.sh to your server like to /root/ossec_agent.sh. You can do this by running:


cd /root && wget https://raw.githubusercontent.com/Gigware/public-cookbooks/master/ossec_agent.sh 

2. Run the script using:

chmod +x /root/ossec_agent.sh && /root/ossec_agent.sh SERVER_NAME AGENT_NAME
</br>
where SERVER_NAME is the name of the actual server and AGENT_NAME of the agent.
