#!/bin/bash

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

#######################################################
# COPIED FROM MANJARO
#######################################################

colors() {
    local fgc bgc vals seq0

    printf "Color escapes are %s\n" '\e[${value};...;${value}m'
    printf "Values 30..37 are \e[33mforeground colors\e[m\n"
    printf "Values 40..47 are \e[43mbackground colors\e[m\n"
    printf "Value  1 gives a  \e[1mbold-faced look\e[m\n\n"

    # foreground colors
    for fgc in {30..37}; do
        # background colors
        for bgc in {40..47}; do
            fgc=${fgc#37} # white
            bgc=${bgc#40} # black

            vals="${fgc:+$fgc;}${bgc}"
            vals=${vals%%;}

            seq0="${vals:+\e[${vals}m}"
            printf "  %-9s" "${seq0:-(default)}"
            printf " ${seq0}TEXT\e[m"
            printf " \e[${vals:+${vals+$vals;}}1mBOLD\e[m"
        done
        echo; echo
    done
}

# Change the window title of X terminals
case ${TERM} in
    xterm*|rxvt*|Eterm*|aterm|kterm|gnome*|interix|konsole*|yakuake*|org.wezfurlong.wezterm*|wezterm*|alacritty*)
        PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\007"'
        ;;
    screen*)
        PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\033\\"'
        ;;
esac

use_color=true

# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS.  Try to use the external file
# first to take advantage of user additions.  Use internal bash
# globbing instead of external grep binary.
safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
match_lhs=""
[[ -f ~/.dir_colors   ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs}    ]] \
    && type -P dircolors >/dev/null \
    && match_lhs=$(dircolors --print-database)
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true

if ${use_color} ; then
    # Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
    if type -P dircolors >/dev/null ; then
        if [[ -f ~/.dir_colors ]] ; then
            eval $(dircolors -b ~/.dir_colors)
        elif [[ -f /etc/DIR_COLORS ]] ; then
            eval $(dircolors -b /etc/DIR_COLORS)
        fi
    fi

    if [[ ${EUID} == 0 ]] ; then
        PS1='\[\033[01;31m\][\h\[\033[01;36m\] \W\[\033[01;31m\]]\$\[\033[00m\] '
    else
        PS1='\[\033[01;32m\][\u@\h\[\033[01;37m\] \W\[\033[01;32m\]]\$\[\033[00m\] '
    fi

    alias grep='grep --colour=auto'
    alias egrep='egrep --colour=auto'
    alias fgrep='fgrep --colour=auto'
else
    if [[ ${EUID} == 0 ]] ; then
        # show root@ when we don't have colors
        PS1='\u@\h \W \$ '
    else
        PS1='\u@\h \w \$ '
    fi
fi

unset use_color safe_term match_lhs sh

xhost +local:root > /dev/null 2>&1

# Check the window size after each command and, if necessary, update the values of LINES and COLUMNS
shopt -s checkwinsize

# Allow to use aliases through script
shopt -s expand_aliases

# Causes bash to append to history instead of overwriting it so if you start a new terminal, you have old session history
shopt -s histappend

# Changed from 'ex' to 'extract', added '.tar.xz', added recursion support
extract() {
    for archive in "$@"; do
        if [ -f "$archive" ] ; then
            case $archive in
                *.tar.xz)    tar xvJf $archive    ;;
                *.tar.bz2)   tar xvjf $archive    ;;
                *.tar.gz)    tar xvzf $archive    ;;
                *.bz2)       bunzip2 $archive     ;;
                *.rar)       unrar x $archive     ;;
                *.gz)        gunzip $archive      ;;
                *.tar)       tar xvf $archive     ;;
                *.tbz2)      tar xvjf $archive    ;;
                *.tgz)       tar xvzf $archive    ;;
                *.zip)       unzip $archive       ;;
                *.Z)         uncompress $archive  ;;
                *.7z)        7z x $archive        ;;
                *)           echo "don't know how to extract '$archive'..." ;;
            esac
        else
            echo "'$archive' is not a valid file!"
        fi
    done
}

#######################################################

iatest=$(expr index "$-" i)

#######################################################
# SOURCED ALIAS'S AND SCRIPTS BY zachbrowne.me
#######################################################

# Source global definitions
if [ -f /etc/bash.bashrc ]; then
    source /etc/bash.bashrc
fi

# Enable bash programmable completion features in interactive shells
if [ -f /usr/share/bash-completion/bash_completion ]; then
    source /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
fi

if [ -f $HOME/.bash_aliases ]; then
    source $HOME/.bash_aliases
fi

if [ -f $HOME/.apps/ble.sh/out/ble.sh ]; then
    source $HOME/.apps/ble.sh/out/ble.sh
fi

#######################################################
# EXPORTS
#######################################################

# Consistent and forever bash history
# START
HISTSIZE=100000
HISTFILESIZE=$HISTSIZE
HISTCONTROL=erasedups:ignorespace:ignoredups

_bash_history_sync() {
  builtin history -a
  HISTFILESIZE=$HISTSIZE
}

_bash_history_sync_and_reload() {
  builtin history -a
  HISTFILESIZE=$HISTSIZE
  builtin history -c
  builtin history -r
}

history() {
  _bash_history_sync_and_reload
  builtin history "$@"
}

export HISTTIMEFORMAT="%d/%m/%y %H:%M:%S   "
PROMPT_COMMAND='history 1 >> ${HOME}/.bash_eternal_history'
PROMPT_COMMAND=_bash_history_sync;$PROMPT_COMMAND
# FINISH

# Disable the bell
if [[ $iatest -gt 0 ]]; then bind "set bell-style visible"; fi

# Allow ctrl-S for history navigation (with ctrl-R)
[[ $- == *i* ]] && stty -ixon

# Ignore case on auto-completion
# Note: bind used instead of sticking these in .inputrc
if [[ $iatest -gt 0 ]]; then bind "set completion-ignore-case on"; fi

# Show auto-completion list automatically, without double tab
if [[ $iatest -gt 0 ]]; then bind "set show-all-if-ambiguous On"; fi

# Set the default editor
export EDITOR=nvim
export VISUAL=nvim

# To have colors for ls and all grep commands such as grep, egrep and zgrep
export CLICOLOR=1
export LS_COLORS='no=00:fi=00:di=00;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:*.xml=00;31:'

# Color for manpages in less makes manpages a little easier to read
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

#######################################################
# SPECIAL FUNCTIONS by Chris Titus Tech
#######################################################

# Use the best version of pico installed
edit()
{
    if [ "$(type -t jpico)" = "file" ]; then
        # Use JOE text editor http://joe-editor.sourceforge.net/
        jpico -nonotice -linums -nobackups "$@"
    elif [ "$(type -t nano)" = "file" ]; then
        nano -c "$@"
    elif [ "$(type -t pico)" = "file" ]; then
        pico "$@"
    else
        nvim "$@"
    fi
}
sedit()
{
    if [ "$(type -t jpico)" = "file" ]; then
        # Use JOE text editor http://joe-editor.sourceforge.net/
        sudo jpico -nonotice -linums -nobackups "$@"
    elif [ "$(type -t nano)" = "file" ]; then
        sudo nano -c "$@"
    elif [ "$(type -t pico)" = "file" ]; then
        sudo pico "$@"
    else
        sudo nvim "$@"
    fi
}

# Searches for text in all files in the current folder
ftext()
{
    # -i case-insensitive
    # -I ignore binary files
    # -H causes filename to be printed
    # -r recursive search
    # -n causes line number to be printed
    # optional: -F treat search term as a literal, not a regular expression
    # optional: -l only print filenames and not the matching lines ex. grep -irl "$1" *
    grep -iIHrn --color=always "$1" . | less -r
}

# Copy files or directories/folders with a progress bar
cprs()
{
    # -a Copies recurse into directories, copies symlinks as symlinks, preserves permissions,
    #    preserves modification times, preserves group and owner, preserves special files
    #
    # -v Verbose
    # -u Overwrite if newer
    #
    # --progress Shows progress during transfer
    if [ -d "${1}" ]; then
        rsync -rlptDvu --progress "${1}/" "${2}"
    else
        rsync -lptDvu --progress "${1}" "${2}"
    fi
}

# Copy files or directories/folder with a progress bar as sudo
scprs()
{
    if [ -d "${1}" ]; then
        sudo rsync -rlptDvu --progress "${1}/" "${2}"
    else
        sudo rsync -lptDvu --progress "${1}" "${2}"
    fi
}

# Copy and go to the directory
cpg()
{
    if [ -d "$2" ];then
        cprs "$1" "$2" && cd "$2"
    else
        cprs "$1" "$2"
    fi
}

# Moves files or directories/folders with a progress bar
mvrs()
{
    # Not trully a move since it copies the files to destination then deletes source files
    #
    # -a Copies recurse into directories, copies symlinks as symlinks, preserves permissions,
    #    preserves modification times, preserves group and owner, preserves special files
    #
    # -v Verbose
    # -u Overwrite if newer
    #
    # --progress Shows progress during transfer
    # --remove-source-files deletes files from source
    if [ -d "${1}" ]; then
        sudo rsync -rlptDvu --progress --remove-source-files "${1}/" "${2}"
        rmd "${1}"
    else
        sudo rsync -lptDvu --progress --remove-source-files "${1}" "${2}"
        #rm "${1}"
    fi
}

# Move and go to the directory
mvg()
{
    if [ -d "$2" ];then
        mvv "$1" "$2" && cd "$2"
    else
        mvv "$1" "$2"
    fi
}

# Create and go to the directory
mkdirg()
{
    mkdir -p "$1"
    cd "$1"
}

# Goes up a specified number of directories  (i.e. up 4)
up()
{
    local d=""
    limit=$1
    for ((i=1 ; i <= limit ; i++))
        do
            d=$d/..
        done
    d=$(echo $d | sed 's/^\///')
    if [ -z "$d" ]; then
        d=..
    fi
    cd $d
}

# Automatically do an ls after each cd
cd()
{
    if [ -n "$1" ]; then
        builtin cd "$@" && ls
    else
        builtin cd ~ && ls
    fi
}

# For some reason, rot13 pops up everywhere
rot13() {
    if [ $# -eq 0 ]; then
        tr '[a-m][n-z][A-M][N-Z]' '[n-z][a-m][N-Z][A-M]'
    else
        echo $* | tr '[a-m][n-z][A-M][N-Z]' '[n-z][a-m][N-Z][A-M]'
    fi
}

# Trim leading and trailing spaces (for scripts)
trim()
{
    local var=$*
    var="${var#"${var%%[![:space:]]*}"}"  # remove leading whitespace characters
    var="${var%"${var##*[![:space:]]}"}"  # remove trailing whitespace characters
    echo -n "$var"
}

# GitHub Titus Additions
gcom() {
    git add .
    git commit -m "$1"
}

# Add commit and push
lazyg() {
    git add .
    git commit -m "$1"
    git push
}

# Saving 3 characters so we don't have to type the extra "it "
gpush() {
    git push
}

alias lookingglass="~/looking-glass-B5.0.1/client/build/looking-glass-client -F"

#######################################################
# "Ultimate amazing command prompt" by Chris Titus Tech
#######################################################

# Install Starship - curl -sS https://starship.rs/install.sh | sh

eval "$(starship init bash)"

#Autojump

if [ -f "/usr/share/autojump/autojump.sh" ]; then
    . /usr/share/autojump/autojump.sh
elif [ -f "/usr/share/autojump/autojump.bash" ]; then
    . /usr/share/autojump/autojump.bash
else
    echo "can't find the autojump script"
fi

#######################################################
# PERSONAL COMMANDS
#######################################################

# Encrypt symmetric
encrypt_sym() {
    encryptfile=$1
    if [[ -d $encryptfile ]]; then
        tar -cf $1.tar.gz $1
        encryptfile=$1.tar.gz
    fi
    gpg -c --no-symkey-cache --cipher-algo AES256 "$encryptfile"
}

# Encrypt asymmetric
encrypt_asym() {
    encryptfile=$1
    if [[ -d $encryptfile ]]; then
        tar -cf $1.tar.gz $1
        encryptfile=$1.tar.gz
    fi
    gpg --no-symkey-cache --cipher-algo AES256 "$encryptfile"
}

# Unencrypt
unencrypt() {
    gpg "$1"
}

# Send notification
notify() {
    notify-send "$1"
}

# Kill app and send notification
killandnotify() {
    killall -9 "$1"
    notify-send "Killed $1"
}

# Make password prompts show "Root Password:" in bold and red
export SUDO_PROMPT="$(tput setaf 1 bold)Root Password:$(tput sgr0) "

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:$HOME/.cargo/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$HOME/.cargo/bin:$PATH"
fi
export PATH

export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:$HOME/.nix-profile/bin

export XDG_DATA_DIRS="$HOME/.nix-profile/share:$XDG_DATA_DIRS"
export XDG_DATA_DIRS="$HOME/.local/share/flatpak/exports/share:$XDG_DATA_DIRS"

export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive

#######################################################
# POST ADDED STUFF
#######################################################
