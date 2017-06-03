#!/usr/bin/env ruby
# frozen_string_literal: true

require "muzak"
require "yaml"

VERSION = 5

OPTS = {
  force: !!(ARGV.delete("--force") || ARGV.delete("-f")),
  playlists: !!(ARGV.delete("--playlists") || ARGV.delete("-p")),
  verbose: !!(ARGV.delete("--verbose") || ARGV.delete("-V")),
  help: !!(ARGV.delete("--help") || ARGV.delete("-h")),
  version: !!(ARGV.delete("--version") || ARGV.delete("-v")),
}

HELP = <<~EOS
  Usage: #{$PROGRAM_NAME} [options] <old> <new>

  Options:
    --force, -f       Perform rebase even if <new> doesn't exist
    --playlists, -p   Rebase playlists as well
    --verbose, -V     Be verbose while rebasing
    --help, -h        Print this help message
    --version, -v     Print version information

  Arguments:
    <old>   The old music tree
    <new>   The new music tree
EOS

def help
  puts HELP
  exit
end

def version
  puts "muzak-rebase-index version #{VERSION}."
  exit
end

def info(msg)
  puts "[\e[32minfo\e[0m]: #{msg}" if OPTS[:verbose]
end

def bail(msg)
  STDERR.puts "[\e[31merror\e[0m]: #{msg}"
  exit 1
end

def force?
  OPTS[:force]
end

help if OPTS[:help]
version if OPTS[:version]

old_root = ARGV.shift
new_root = ARGV.shift

help unless old_root && new_root

if !Dir.exist?(new_root) && !force?
  bail "'#{new_root}' doesn't exist or isn't a directory, not continuing without --force."
end

bail "You don't have an index file." unless File.exist?(Muzak::Config::INDEX_FILE)

info "Replacing '#{old_root}' with '#{new_root}' in your index..."

Muzak::Config.music = new_root

old_root = File.absolute_path(old_root)
new_root = File.absolute_path(new_root)

index_hash = Marshal.load File.read(Muzak::Config::INDEX_FILE)

index_hash["artists"].each do |_, artist|
  artist["albums"].each do |_, album|
    album["songs"].each do |song_path|
      song_path.gsub! old_root, new_root
    end

    album["cover"]&.gsub! old_root, new_root

    album["deep-songs"].each do |song|
      # This is bad, but making an exception out of Song#path and adding
      # a writer feels equally bad.
      song.instance_variable_set(:@path, song.path.gsub(old_root, new_root))
    end
  end
end

File.write(Muzak::Config::INDEX_FILE, Marshal.dump(index_hash))

if OPTS[:playlists]
  Muzak::Playlist.playlist_names.each do |pname|
    pfile = Muzak::Playlist.path_for(pname)

    playlist_hash = YAML.load_file(pfile).clone

    playlist_hash["songs"].each do |song|
      if song.path.nil?
        playlist_hash["songs"].delete(song)
        next
      end
      song.instance_variable_set(:@path, song.path.gsub(old_root, new_root))
    end

    File.write(pfile, playlist_hash.to_yaml)
  end
end

info "all done."
