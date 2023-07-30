#!/usr/bin/ruby
require 'json'

CF_TUNNEL_CONFIG_DEFAULT = [{
	"service": "http_status:404"
}]
DEFAULT_CF_TUNNEL_CONFIG_LOCATION = "/home/dokku/.cf-tunnel-config"

puts "Reading /home/dokku/.cf-tunnel-config file, if it exists, or using default"

if File.exists?(DEFAULT_CF_TUNNEL_CONFIG_LOCATION)
	cf_tunnel_config_file = File.read(DEFAULT_CF_TUNNEL_CONFIG_LOCATION)
	cf_tunnel_config_file_contents_as_json = JSON.parse(
		cf_tunnel_config_file.tr("\n","").tr(" ","")
	)
end

cf_tunnel_config = cf_tunnel_config_file_contents_as_json || CF_TUNNEL_CONFIG_DEFAULT

puts "Updating ingress list with current apps"
dokku_app_list = `dokku apps:list`.split("\n")[1..-1]

dokku_app_list.each do |dokku_app|
	hostname = `dokku domains:report #{dokku_app} --domains-app-vhosts`
	service = `cat /home/dokku/#{dokku_app}/nginx.conf | grep "server .*5000" | awk '$1 == "server" {print $2}' | cut -f1 -d";"`
	if hostname && service
		cf_tunnel_config.push({
			hostname: hostname,
			service: service
		})
	end
end

puts cf_tunnel_config
