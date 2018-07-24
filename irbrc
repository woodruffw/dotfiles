#!/usr/bin/env ruby
# frozen_string_literal: true

def requireish(lib)
  require lib
  yield if block_given?
rescue LoadError => e
  STDERR.puts "#{e.class}: #{e}"
end

MODULES = [
  "irb/completion",
  "open-uri",
  "json",
  "yaml",
  "net/http",
  "digest/sha1",
  "digest/md5",
  "base64",
  "irbtools",
].freeze

MODULES.each do |m|
  requireish m
end

requireish "awesome_print" do
  AwesomePrint.irb!
end

IRB.conf[:PROMPT_MODE] = :SIMPLE
IRB.conf[:AUTO_INDENT] = true

IRB.conf[:SAVE_HISTORY] = 1000
IRB.conf[:EVAL_HISTORY] = 100
IRB.conf[:HISTORY_FILE] = "#{ENV["HOME"]}/.irbhist"
