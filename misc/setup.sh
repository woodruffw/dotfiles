#!/usr/bin/env bash

# UNFINISHED

function fatal {
	1>&2 printf "Fatal: %s\n" "${*}"
	exit 1
}

function info {
	printf "Info: %s\n" "${*}"
}

info "Checking the distro before continuing."

[[ -f /etc/os-release ]] || fatal "This script only works on Ubuntu."
distro=$(awk -F= '/^NAME/{print $2}' /etc/os-release | tr -d '"')
[[ "${distro}" = "Ubuntu" ]] || fatal "This script only works on Ubuntu."
ubuntu_version=$(lsb_release -r | cut -f2)
[[ "${ubuntu_version}" = "14.04" ]] || fatal "This script only works on Ubuntu ${ubuntu_version}."

info "Looks like we're on Ubuntu ${ubuntu_version}. Continuing."

info "Updating and upgrading first."

sudo apt-get update
yes | sudo apt-get upgrade

info "Finished updating and upgrading."

info "Installing core packages."

# install core packages

core_pkgs=(
	hexchat
	mpv
	feh
	xclip
	xscreensaver
	xbindkeys
	xbindkeys-config
	xfonts-terminus
	rxvt-unicode
	textadept
	vim
	tilda
	rtorrent
	gawk
	tmux
	thunar
	thunderbird
	firefox
	gpick
	# texmaker # not for now
	ttf-mscorefonts-installer
	audacity
	dconf-editor
	unity-tweak-tool
	timidity
	nautilus-dropbox
	build-essential
	git
)

yes | sudo apt-get install "${core_pkgs[@]}"

info "Core packages installed. Moving on to PPAs."

info "Installing vertex-theme."
sudo sh -c "echo 'deb http://download.opensuse.org/repositories/home:/Horst3180/xUbuntu_${ubuntu_version}/ /' >> /etc/apt/sources.list.d/vertex-theme.list"
sudo apt-get update
yes | sudo apt-get install vertex-theme
info "Finished with vertex-theme."

info "Installing mpv from mpv-tests."
yes | sudo add-apt-repository ppa:mc3man/mpv-tests
sudo apt-get update
yes | sudo apt-get install mpv
info "Finished with mpv."

info "Installing Sublime Text 3."
yes | sudo add-apt-repository ppa:webupd8team/sublime-text-3
sudo apt-get update
yes | sudo apt-get install sublime-text-installer
info "Finished with Sublime Text 3."

info "Removing some cruft."

cruft=(unity-lens-friends unity-scope-audacious unity-scope-chromiumbookmarks
	unity-scope-clementine unity-scope-colourlovers unity-scope-devhelp
	unity-scope-firefoxbookmarks unity-scope-gdrive unity-scope-gmusicbrowser
	unity-scope-gourmet unity-scope-guayadeque unity-scope-manpages
	unity-scope-musicstores unity-scope-musique unity-scope-openclipart
	unity-scope-texdoc unity-scope-tomboy unity-scope-video-remote
	unity-scope-virtualbox unity-scope-yelp unity-scope-zotero
	unity-lens-friends unity-lens-music unity-lens-photos unity-lens-video)

yes | sudo apt-get purge "${@}"
info "Finished removing cruft."

info "Removing bad defaults."

gsettings set org.gnome.settings-daemon.plugins.media-keys terminal ''
gsettings set org.gnome.settings-daemon.plugins.media-keys window-screenshot ''
gsettings set org.gnome.settings-daemon.plugins.media-keys screenshot-clip ''
gsettings set org.gnome.settings-daemon.plugins.media-keys window-screenshot-clip ''
gsettings set org.gnome.settings-daemon.plugins.media-keys area-screenshot-clip ''
gsettings set org.gnome.settings-daemon.plugins.media-keys area-screenshot ''
gsettings set org.gnome.settings-daemon.plugins.media-keys screenshot ''
gsettings set org.gnome.settings-daemon.plugins.media-keys screensaver ''

info "Finished removing bad defaults."

info "Setting new defaults."

gsettings set org.gnome.desktop.wm.preferences theme 'Vertex-Dark'
gsettings set org.gnome.desktop.background picture-uri ''
gsettings set org.gnome.desktop.background picture-opacity '100'
gsettings set org.gnome.desktop.background picture-options 'none'
gsettings set org.gnome.desktop.background primary-color '#88888a8a8585'
gsettings set org.gnome.desktop.background secondary-color '#5789ca'
gsettings set org.gnome.desktop.background color-shading-type 'solid'
gsettings set org.gnome.desktop.background draw-background 'true'
gsettings set org.gnome.desktop.background show-desktop-icons 'false'

info "Finished setting new defaults."

# sync dotfiles



