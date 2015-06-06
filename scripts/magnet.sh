#!/usr/bin/env bash

# magnet.sh: Convert a magnet URI into a rtorrent-readable .torrent
# Adapted from http://wiki.rtorrent.org/MagnetUri

function usage() {
	echo "Usage: $0 <magnet URI>"
	exit 1
}

[[ "$1" =~ xt=urn:btih:([^&/]+) ]] || usage

hashh=${BASH_REMATCH[1]}

if [[ "$1" =~ dn=([^&/]+) ]];then
	filename=${BASH_REMATCH[1]}
else
	filename=$hashh
fi

echo "d10:magnet-uri${#1}:${1}e" > "meta-$filename.torrent"
