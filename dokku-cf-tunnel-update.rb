#!/usr/bin/ruby

CF_TUNNEL_CONFIG_DEFAULT = ",{\"service\": \"http_status:404\"}"

puts "Reading /home/dokku/.cf-tunnel-config file, if it exists, or using default"
cf_tunnel_config_file_contents = `cat /home/dokku/.cf-tunnel-config`
cf_tunnel_config = !cf_tunnel_config_file_contents ? CF_TUNNEL_CONFIG_DEFAULT : cf_tunnel_config_file_contents

puts "Updating ingress list"
dokku_app_list = `dokku apps:list`.split("\n")[1..-1]

ingress_list = []
dokku_app_list.each do |dokku_app|
	hostname = `dokku domains:report #{dokku_app} --domains-app-vhosts`
	service = `cat /home/dokku/#{dokku_app}/nginx.conf | grep "server .*5000" | awk '$1 == "server" {print $2}' | cut -f1 -d";"`
	ingress_list.push({
		hostname: hostname,
		service: service
	})
end

puts ingress_list
