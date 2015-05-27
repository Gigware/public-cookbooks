#!/usr/bin/ruby

require 'rubygems'
require 'fileutils'
require 'logger'
require 'optparse'
require 'net/ssh'

@logger = Logger.new(STDOUT)
@logger.level = Logger::INFO
@options={}
@config_lines=[]

def getopts()
 retopts=""
 optparse = OptionParser.new do |opts|
  opts.banner = "Usage: #{$PROGRAM_NAME} [options]"
  opts.on_tail( '--ossec-server-name hostname', 'The hostname of the ossec server to be used' ) do |server_name|
   @options[:server_name] = server_name
  end
  opts.on_tail( '--agent-name agent', 'The name of the agent to be used' ) do |agent_name|
   @options[:agent_name] = agent_name
  end
  opts.on_tail( '--agent-server-ip ip/hostname', 'The IP or hostname of the server where ossec agent should be installed' ) do |ossec_agent_server|
   @options[:ossec_agent_server] = ossec_agent_server
  end
  opts.on_tail( '--private-key /path/to/key', 'The path to the private key to be used' ) do |private_key|
   @options[:private_key] = private_key
  end
  opts.on_tail( '--ssh-user user', 'The username to be used on the server to be chefized' ) do |username|
   @options[:username] = username
  end
  opts.on_tail( '--help', 'Show Help' ) do
   puts(opts)
   exit(0)
  end
 @retopts=opts
 end
 optparse.parse!
 if @options[:server_name] == nil or @options[:ossec_agent_server] == nil or @options[:private_key] == nil or @options[:username] == nil
  puts(@retopts)
  exit(1)
 end
end

def set_config()
 @config_lines.push("echo 'agent_server_ip=#{@options[:server_name]}' | sudo tee --append /etc/ossec_config.conf > /dev/null")
 if @options[:agent_name] != nil
  @config_lines.push("echo 'agent_name=#{@options[:agent_name]}' | sudo tee --append /etc/ossec_config.conf > /dev/null")
 end
end

def remove_known_host()
 buf_output=`sed -i "s/^.$#{@options[:ossec_agent_server]}.*$//g" /root/.ssh/known_hosts`
end

def run_pre_chefization()
 begin
  @session = Net::SSH.start( @options[:ossec_agent_server], @options[:username], :keys => [ @options[:private_key] ], :compression => "zlib", :port=> 22 )
  @config_lines.each do |line|
   @session.open_channel do |channel_obj|
    channel_obj.request_pty
    channel_obj.exec(line)
    channel_obj.on_data do |channel_buf, data|
     result = "#{result}#{data}"
    end
   end
   @session.loop
  end
  @session.close()
 rescue => e
  @logger.error "Cannot run ssh commands or connect to #{@options[:ossec_agent_server]} due to error:#{e.message}"
  exit(1)
 end
end

def get_chef_host()
 begin
  file = File.open("/root/.chef/knife.rb", 'r')
  file.each do |line|
   if line =~ /chef_server_url/
    @chef_host=line.gsub(/^.*https:\/\/|:443.*|\n$/,'')
   end
  end
  file.close()
 rescue => e
  @logger.error "Cannot get the chef hostname due to error:#{e.message}"
  exit(1)
 end
end

def run_chefization()
 get_chef_host()
 exec("knife bootstrap #{@options[:ossec_agent_server]} -s https://#{@chef_host} -x #{@options[:username]} -i #{@options[:private_key]} --node-ssl-verify-mode none --sudo --run-list role[ossec_agent]")
end

getopts()
set_config()
remove_known_host()
run_pre_chefization()
run_chefization()
