#!/usr/bin/ruby
require 'json'
require 'net/http'
require 'pry'

DEFAULT_CF_TUNNEL_CONFIG_LOCATION = "/home/dokku/.cf-tunnel-config"

puts "Reading /home/dokku/.cf-tunnel-config file, if it exists, or using default"

if File.exists?(DEFAULT_CF_TUNNEL_CONFIG_LOCATION)
	cf_tunnel_config_file = File.read(DEFAULT_CF_TUNNEL_CONFIG_LOCATION)
	cf_tunnel_config_file_contents_as_json = JSON.parse(
		cf_tunnel_config_file.tr("\n","").tr(" ","")
	)
end

cf_tunnel_config = cf_tunnel_config_file_contents_as_json || []	

puts "Updating ingress list with current apps"
dokku_app_list = `dokku apps:list`.split("\n")[1..-1]

dokku_app_list.each do |dokku_app|
	hostname = `dokku domains:report #{dokku_app} --domains-app-vhosts`.tr("\n","")
	service = `cat /home/dokku/#{dokku_app}/nginx.conf | grep "server .*5000" | awk '$1 == "server" {print $2}' | cut -f1 -d";"`.tr("\n","")
	if hostname && hostname != "" && service && service != ""
		cf_tunnel_config.push({
			"hostname" => hostname,
			"service" => "http://#{service}"
		})
	end
end

cf_tunnel_config.push({
	"service" => "http_status:404"
})

puts cf_tunnel_config

cf_account_uuid = ENV['CF_ACCOUNT_UUID']
cf_tunnel_uuid = ENV['CF_TUNNEL_UUID']
cloudflare_api_url = "https://api.cloudflare.com/client/v4/accounts/#{cf_account_uuid}/cfd_tunnel/#{cf_tunnel_uuid}/configurations"

cf_auth_token = ENV['CF_AUTH_TOKEN']
headers = {
  'Content-Type' => 'application/json',
  'Authorization' => "Bearer #{cf_auth_token}"
}

# Set up the request body
data = {
  "config": {
    "ingress": cf_tunnel_config
  }
}

binding.pry

uri = URI(cloudflare_api_url)
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

request = Net::HTTP::Put.new(uri.path, headers)
request.body = data.to_json

response = http.request(request)

# Handle the response
puts "Cloudflare API Response code: #{response.code}"
puts "Cloudflare API Response body: #{response.body}"
