1. Install this cookbook on your chef server using ```knife cookbook install ossec_agent_server``` after putting it into the /var/chef/cookbooks directory.


2. Create a role named ossec_agent containing this cookbook, this can be done easily using the chef web interface under the roles section(Under Policy -> Roles push Create and assign the cookbook)

3. Create a databag that will contain the server hostname using the next commands:
knife data bag create ossec
echo "{\"id\":\"user\", \"agent_server_ip\":\"ServerName\"}" > ossec.json
knife data bag from file ossec ossec.json
rm -f ossec.json

Where ServerName is the actual hostname of the server.
