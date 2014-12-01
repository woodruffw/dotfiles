#!/usr/bin/env ruby

require 'sendgrid-ruby'
require 'socket'
require 'net/http'

host = Socket.gethostname
uptime = `uptime`
internal_ip = Socket.ip_address_list.detect{|ip| ip.ipv4_private?}.nil?.ip_address

rescue NoMethodError
	internal_ip = "None."
end

external_ip = Net::HTTP.get(URI('http://ipecho.net/plain'))
disks = `df -h`

client = SendGrid::Client.new do |c|
	c.api_user = ENV['SENDGRID_API_USER']
	c.api_key = ENV['SENDGRID_API_PASS']
end

mail = SendGrid::Mail.new do |m|
	m.from = "dailymail@#{host}"
	m.to = 'william@tuffbizz.com'
	m.subject = "Daily report for #{host}"
	m.text = %{Greetings from #{host}!
Uptime: #{uptime}
Internal IP: #{internal_ip}
External IP: #{external_ip}
Disk status:
#{disks}}
end

client.send(mail)