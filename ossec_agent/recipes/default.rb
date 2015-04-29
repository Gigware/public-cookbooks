case node['os']
when "linux"
  install_cmds = value_for_platform(
    ["ubuntu"] => {
	  "12.04" => ["apt-key adv --fetch-keys http://ossec.wazuh.com/repos/apt/conf/ossec-key.gpg.key", "echo 'deb http://ossec.wazuh.com/repos/apt/ubuntu precise main' >> /etc/apt/sources.list", "apt-get update"],
	  "14.04" => ["apt-key adv --fetch-keys http://ossec.wazuh.com/repos/apt/conf/ossec-key.gpg.key", "echo 'deb http://ossec.wazuh.com/repos/apt/ubuntu trusty main' >> /etc/apt/sources.list", "apt-get update"],
	  "14.10" => ["apt-key adv --fetch-keys http://ossec.wazuh.com/repos/apt/conf/ossec-key.gpg.key", "echo 'deb http://ossec.wazuh.com/repos/apt/ubuntu utopic main' >> /etc/apt/sources.list", "apt-get update"],
      "default" => ["apt-key adv --fetch-keys http://ossec.wazuh.com/repos/apt/conf/ossec-key.gpg.key", "echo 'deb http://ossec.wazuh.com/repos/apt/ubuntu precise main' >> /etc/apt/sources.list", "apt-get update"]
    },
    ["debian"] => {
	  "8.0" => ["apt-key adv --fetch-keys http://ossec.wazuh.com/repos/apt/conf/ossec-key.gpg.key", "echo 'deb http://ossec.wazuh.com/repos/apt/debian jessie main' >> /etc/apt/sources.list", "apt-get update"],
	  "7.0" => ["apt-key adv --fetch-keys http://ossec.wazuh.com/repos/apt/conf/ossec-key.gpg.key", "echo 'deb http://ossec.wazuh.com/repos/apt/debian wheezy main' >> /etc/apt/sources.list", "apt-get update"],
	  "6.0" => ["apt-key adv --fetch-keys http://ossec.wazuh.com/repos/apt/conf/ossec-key.gpg.key", "echo 'deb http://ossec.wazuh.com/repos/apt/debian sid main' >> /etc/apt/sources.list", "apt-get update"],
      "default" => ["apt-key adv --fetch-keys http://ossec.wazuh.com/repos/apt/conf/ossec-key.gpg.key", "echo 'deb http://ossec.wazuh.com/repos/apt/debian wheezy main' >> /etc/apt/sources.list", "apt-get update"]
    },
    ["centos", "redhat", "fedora", "amazon"] => {
      "default" => ["wget -q -O - https://www.atomicorp.com/installers/atomic | sh"]
    }
  )
  install_packs = value_for_platform(
   ["ubuntu", "debian"] => {"default" => ["ossec-hids-agent"]},
   ["centos", "redhat", "fedora", "amazon"] => {"default" => ["ossec-hids-client"]}
  )
 
 install_cmds.each do |command|
  execute "#{command}" do
   not_if { ::File.exists?("/var/ossec/etc/ossec.conf")}
  end
 end
 
 install_packs.each do |pkg|
  package pkg do
   action :install
  end
 end

 end
