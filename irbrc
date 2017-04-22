MODULES = [
	'irb/completion',
	'open-uri',
	'json',
	'yaml',
	'net/http',
	'digest/sha1',
	'digest/md5'
]

MODULES.each do |m|
	begin
		require m
	rescue LoadError => e
		puts "#{e.class}: #{e.to_s}"
	end
end

# load awesome_print manually because of the irb! call
begin
	require 'awesome_print'
	AwesomePrint.irb!
rescue LoadError
end

begin
	require "irbtools"
rescue LoadError
end

IRB.conf[:PROMPT_MODE] = :SIMPLE
IRB.conf[:AUTO_INDENT] = true

IRB.conf[:SAVE_HISTORY] = 1000
IRB.conf[:EVAL_HISTORY] = 100
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irbhist"
