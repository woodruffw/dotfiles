#!/usr/bin/env ruby
# frozen_string_literal: true

require "muzak"
require "json"

def now_playing
  json = JSON.parse(`muzak-cmd now-playing`)

  return if json["response"]["error"]

  json["response"]["data"]["playing"]
end

# don't bother printing if it's nil or empty
puts now_playing unless now_playing&.empty?
