1. Install this cookbook on your chef server using ```knife cookbook install ossec_agent_server``` after putting it into the /var/chef/cookbooks directory.


2. Create a role named ossec_agent containing this cookbook, this can be done easily using the chef web interface under the roles section(Under Policy -> Roles push Create and assign the cookbook)

3. Use the ```https://github.com/Gigware/public-cookbooks/blob/master/chefize_ossec.rb``` script to chefize the server with ossec agent using this script(required to install the net-ssh gem like ```gem install net-ssh```. Script usage is:


   Usage: ./chefize_ossec.rb [options]<br>
        --ossec-server-name hostname The hostname of the ossec server to be used<br>
        --agent-name agent           The name of the agent to be used<br>
        --agent-server-ip ip/hostname<br>
                                     The IP or hostname of the server where ossec agent should be installed<br>
        --private-key /path/to/key   The path to the private key to be used<br>
        --ssh-user user              The username to be used on the server to be chefized<br>
        --help                       Show Help<br>

Where --ossec-server-name is the hostname of the ossec server to be used, --agent-name can be optional - if not specified then the instance ID will be used or the actual instance hostname if no instance ID present, --agent-server-ip is the IP of the instance, --private-key is the private key to be used and --ssh-useris the username.
