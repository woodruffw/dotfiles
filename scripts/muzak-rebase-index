#!/usr/bin/env ruby

require "muzak"
require "yaml"

VERSION = 3

def help
  puts <<~EOS
    Usage: #{$PROGRAM_NAME} <directory> [options]

    Options:
      --force, -f       Perform rebase even if <directory> doesn't exist
      --help, -h        Print this help message
      --version, -v     Print version information

    Arguments:
      <directory>   The new music root
  EOS

  exit
end

def version
  puts "muzak-rebase-index version #{VERSION}."

  exit
end

def info(msg)
  puts "[\e[32minfo\e[0m]: #{msg}"
end

def bail(msg)
  STDERR.puts "[\e[31merror\e[0m]: #{msg}"
  exit 1
end

def force?
  ARGV.include?("--force") || ARGV.include?("-f")
end

help if ARGV.include?("--help") || ARGV.include?("-h")
version if ARGV.include?("--version") || ARGV.include?("-v")

new_root = ARGV.shift

help unless new_root

if !Dir.exist?(new_root) && !force?
  bail "'#{new_root}' doesn't exist or isn't a directory, not continuing without --force."
end

bail "You don't have an index file." unless File.exist?(Muzak::INDEX_FILE)

info "Replacing '#{Muzak::Config.music}' with '#{new_root}' in your config and index..."

Muzak::Config.music = new_root

orig_root = File.absolute_path(Muzak::Config.music)
new_root = File.absolute_path(new_root)

index_hash = Marshal.load(File.read Muzak::INDEX_FILE)

index_hash["artists"].each do |_, artist|
  artist["albums"].each do |_, album|
    album["songs"].each do |song_path|
      song_path.gsub! orig_root, new_root
    end

    album["deep-songs"].each do |song|
      # This is bad, but making an exception out of Song#path and adding
      # a writer feels equally bad.
      song.instance_variable_set(:@path, song.path.gsub(orig_root, new_root))
    end
  end
end

Muzak::Playlist.playlist_names.each do |pname|
  pfile = Muzak::Playlist.path_for(pname)

  puts pfile

  playlist_hash = YAML.load_file(pfile).clone

  playlist_hash["songs"].each do |song|
    puts orig_root
    song.instance_variable_set(:@path, song.path.gsub(orig_root, new_root))
  end

  File.write(pfile, playlist_hash.to_yaml)
end

File.write(Muzak::INDEX_FILE, Marshal.dump(index_hash))

info "All done."
