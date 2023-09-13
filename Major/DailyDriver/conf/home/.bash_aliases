#######################################################
# GENERAL ALIAS'S
#######################################################
# To temporarily bypass an alias, we precede the command with a \
# EG: the ls command is aliased, but to use the normal ls command you would type \ls

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Edit this .bashrc file
alias ebrc='edit ~/.bashrc'

# alias to show the date
alias da='date "+%d/%m/%Y %A %T %Z"'

# Alias's to modified commands
alias cp='cp -iv'
alias cpf='cp -fv'
alias mv='mv -iv'
alias mvf='mv -fv'
alias rmf='/bin/rm --force --verbose '
alias mkdir='mkdir -p'
alias ls='ls -a'
alias ping='ping -c 10'
alias less='less -R'
alias cls='clear'
alias vi='nvim'
alias vim='nvim'
alias svi='sudo vi'
alias sudo='sudo -v; sudo '

# Change directory aliases
alias home='cd ~'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# cd into the old directory
alias bd='cd "$OLDPWD"'

# Remove a directory and all files
alias rmd='/bin/rm  --recursive --verbose '
alias rmdf='/bin/rm  --recursive --force --verbose '

# Alias's for multiple directory listing commands
alias la='ls -Alh' # show hidden files
alias ls='ls -aFh --color=always' # add colors and file type extensions
alias lx='ls -lXh' # sort by extension
alias lk='ls -lSrh' # sort by size
alias lc='ls -ltrh --sort time' # sort by change time
alias lr='ls -lRh' # recursive ls
alias lt='ls -lrh --date date' # sort by date
alias ll='ls -FlS' # long listing format
alias lff="ls -l --group-dirs=first" # directories first
alias ldl="ls -l --group-dirs=last" # directories last
alias lf="ls -l | egrep -v '^d'" # files only
alias ldir="ls -l | egrep '^d'" # directories only

# alias chmod commands
alias mx='chmod a+x'
alias 000='chmod -R 000'
alias 644='chmod -R 644'
alias 666='chmod -R 666'
alias 755='chmod -R 755'
alias 777='chmod -R 777'

# Search command line history
alias h="history | grep "

# Search running processes
alias p="ps aux | grep "
alias topcpu="/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"

# Search files in the current folder
alias f="find . | grep "

# Count all files (recursively) in the current folder
alias countfiles="for t in files links directories; do echo \`find . -type \${t:0:1} | wc -l\` \$t; done 2> /dev/null"

# To see if a command is aliased, a file, or a built-in command
alias checkcommand="type -t"

# Show open ports
alias openports='netstat -nape --inet'

# Alias's for safe and forced reboots
alias rebootsafe='sudo shutdown -r now'
alias rebootforce='sudo shutdown -r -n now'

# Alias's to show disk space and space used in a folder
alias diskspace="du -S | sort -n -r |more"
alias folders='du -h --max-depth=1'
alias folderssort='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'
alias tree='tree -CAhF --dirsfirst'
alias treed='tree -CAFd'
alias mountedinfo='df -hT'

# Alias's for archives
alias mktar='tar -cvf'
alias mkbz2='tar -cvjf'
alias mkgz='tar -cvzf'
alias untar='tar -xvf'
alias unbz2='tar -xvjf'
alias ungz='tar -xvzf'

# Show all logs in /var/log
alias logs="sudo find /var/log -type f -exec file {} \; | grep 'text' | cut -d' ' -f1 | sed -e's/:$//g' | grep -v '[0-9]$' | xargs tail -f"

# SHA1
alias sha1='openssl sha1'

alias clickpaste='sleep 3; xdotool type "$(xclip -o -selection clipboard)"'

# NIX

# Alias to rebuild home-manager
alias hmswitch='home-manager switch --impure'

# Alias to clean home-manager
alias hmclean='nix store optimise && home-manager switch -b backup --impure && nix-store --gc --print-roots | grep -v "/nix/store/" | xargs -r nix-store --delete && nix-store --gc && sudo systemctl restart nix-daemon && echo "done"'

# Alias to optimise nix store (Replaces identical files in nix store by hard links)
alias nixoptimise='nix store optimise'

# Alias to rebuild home-manager
alias hmbuild='home-manager build'

# Alias to update flake inputs
#alias flakeupdate='nix flake update $HOME/.config/home-amanager/'

# Alias to upgrade nix instead of manually running all these commmands
#alias nixupgrade='sudo nix-channel --update && sudo nix-env --install --attr nixpkgs.nix nixpkgs.cacert && sudo systemctl daemon-reload && sudo systemctl restart nix-daemon'

# PLASMA

# Restart Plasma, only works for KDE 5.10 or higher
alias restartplasma='kquitapp5 plasmashell || killall plasmashell && kstart5 plasmashell &'

# Restart sxhkd
alias restartsxhkd='killandnotify "sxhkd" && notify "sxhkd reloaded" && sxhkd &'

# Restart kwin
alias restartkwin='kwin_x11 --replace &'

# Restart kwin and plasma
alias restartdesktop='restartkwin restartplasma'

# Update system instead of manually typing
alias updatesystem='sudo pacman -Syy && paru -Su && flatpak update -y'

# Flatpak apps

# Flatseal
alias flatseal='com.github.tchx84.Flatseal &'

# Firefox
alias firefox='org.mozilla.firefox --ProfileManager &'

# Steam
alias steam='com.valvesoftware.Steam &'

# Discord
alias discord='com.discordapp.Discord &'

# ProtonUp Qt
alias protonup='net.davidotek.pupgui2 &'

# Protontricks
alias protontricks='com.github.Matoking.protontricks &'

# Lutris
alias lutris='net.lutris.Lutris &'

# Github Desktop
alias github-desktop='io.github.shiftey.Desktop &'

# Spotify
alias spotify='com.spotify.Client &'

# Mission Center
alias mission-center='io.missioncenter.MissionCenter &'

# Tenacity
alias tenacity='org.tenacityaudio.Tenacity &'

# Wine
alias wine='flatpak run org.winehq.Wine'

# Winetricks
alias winetricks='flatpak run --command=winetricks org.winehq.Wine'

# Winecfg
alias winecfg='flatpak run --command=winecfg org.winehq.Wine'

# Wineboot
alias wineboot='flatpak run --command=wineboot org.winehq.Wine'

# Bottles
alias bottles='flatpak run com.usebottles.bottles &'

alias restartsxhkd='killandnotify "sxhkd" && notify "sxhkd reloaded" && sxhkd &'
alias restartkwin='kwin_x11 --replace &'
alias restartdesktop='restartlatte restartkwin restartplasma'
alias restartswhkd='killall -9 swhks && sudo killall -9 swhkd &&  notify "swhks reloaded" && notify "swhkd reloaded" && swhks & pkexec swhkd &'

#######################################################
# POST ADDED ALIAS'S
#######################################################
