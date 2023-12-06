#!/bin/sh

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# Set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# Set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi


#if [ -d $HOME/.nix-profile/etc/profile.d ]; then
#  for i in $HOME/.nix-profile/etc/profile.d/*.sh; do
#    if [ -r $i ]; then
#      . $i
#    fi
#  done
#fi

export PIPEWIRE_LATENCY="64/48000"
