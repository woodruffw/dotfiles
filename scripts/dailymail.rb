#!/usr/bin/env ruby

require 'sendmail-api'
require 'socket'
require 'net/http'

host = Socket.gethostname
uptime = `uptime`
internal_ip = Socket.ip_address_list.detect{|ip| ip.ipv4_private?}.ip_address
external_ip = Net::HTTP.get('http://ipecho.net/plain')
disks = `df -h`

client = SendGrid::Client.new do |c|
	c.api_user = ENV['SENDGRID_API_USER']
	c.api_key = ENV['SENDGRID_API_PASS']
end

mail = SendGrid::Mail.new do |m|
	m.from = "dailymail@#{host}"
	m.to = 'william@tuffbizz.com'
	m.subject = "Daily report for #{host}"
	m.text = %{
		Uptime: #{uptime}
		Internal IP: #{internal_ip}
		External IP: #{external_ip}
		Disk status:
		#{disks}
	}
end

client.send(mail)
