1. Install this cookbook on your chef server using ```knife cookbook install ossec_agent_server``` after putting it into the /var/chef/cookbooks directory.


2. Create a role named ossec_agent containing this cookbook, this can be done easily using the chef web interface under the roles section(Under Policy -> Roles push Create and assign the cookbook)

3. Use the ```https://github.com/Gigware/public-cookbooks/blob/master/chefize_ossec.rb``` script to chefize the server with ossec agent using this script(required to install the net-ssh gem like ```gem install net-ssh```. Script usage is:


```Usage: ./chefize_ossec.rb [options]<br>
        --ossec-server-name hostname The hostname of the ossec server to be used<br>
        --agent-name agent           The name of the agent to be used<br>
        --agent-server-ip ip/hostname<br>
                                     The IP or hostname of the server where ossec agent should be installed<br>
        --private-key /path/to/key   The path to the private key to be used<br>
        --ssh-user user              The username to be used on the server to be chefized<br>
        --help                       Show Help<br>```




where SERVER_NAME is the name of the actual server and AGENT_NAME of the agent. If no AGENT_NAME specified, the instance ID will be used as agent name, otherwise the hostname.

NOTE: CentOs5/Rhel5 platform may be missing EL5 'git' in the official repos, you should run the next command prior to taking steps 1 and 2:

    rpm -Uvh http://dl.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm
