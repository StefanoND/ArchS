#!/bin/bash

RC='\e[0m'
RED='\e[31m'
YELLOW='\e[33m'
GREEN='\e[32m'

checkEnv() {
    ## Check if the current directory is writable.
    GITPATH="$(dirname "$(realpath "$0")")"
    if [[ ! -w ${GITPATH} ]]; then
        echo -e "${RED}Can't write to ${GITPATH}${RC}"
        exit 1
    fi

    ## Check for requirements.
    REQUIREMENTS='curl paru sudo'
    if ! which ${REQUIREMENTS}>/dev/null;then
        echo -e "${RED}To run me, you need: ${REQUIREMENTS}${RC}"
        exit 1
    fi

    ## Check if member of the wheel group.
    if ! groups|grep wheel>/dev/null;then
        echo -e "${RED}You need to be a member of the wheel to run me!"
        exit 1
    fi
}

installDepend() {
    PKGS=(
        'sxhkd'
        'wezterm'
        'wezterm-shell-integration'
        'wezterm-terminfo'
        'bash'
        'bash-completion'
        'startship'
    )

    for PKG in "${PKGS[@]}"; do
        if ! pacman -Q | grep -q "${PKG}"; then
            echo
            echo "INSTALLING: ${PKG}"
            echo
            sudo pacman -S "$PKG" --noconfirm --needed
            sleep 1s
        fi
    done

    if ! paru -Q | grep -q autojump; then
        echo
        echo "INSTALLING: autojump"
        echo
        paru -S autojump --noconfirm --needed --sudoloop
        sleep 1s
    fi
    sudo mkdir /usr/local/bin/autojump
    sudo ln -s /etc/profile.d/autojump.sh /usr/share/autojump/autojump.sh
    sudo chmod +x /usr/share/autojump/autojump.sh
}

installStarship(){
    if pacman -Q | grep -q starship; then
        echo "Starship already installed"
        return
    else
        echo "Installing Starship"
        sudo pacman -S starship --noconfirm --needed
    fi
}

linkConfig() {
    ## Check if a bashrc file is already there.
    OLD_BASHRC="${HOME}/.bashrc"
    if [[ -e ${OLD_BASHRC} ]]; then
        echo -e "${YELLOW}Moving old bash config file to ${HOME}/.bashrc.bak${RC}"
        if ! mv ${OLD_BASHRC} ${HOME}/.bashrc.bak; then
            echo -e "${RED}Can't move the old bash config file!${RC}"
            exit 1
        fi
    fi

    echo -e "${YELLOW}Linking new bash config file...${RC}"
    ## Make symbolic link.
    ln -svf ${GITPATH}/.bashrc ${HOME}/.bashrc
    ln -svf ${GITPATH}/starship.toml ${HOME}/.config/starship.toml
}

checkEnv
installDepend
installStarship
if linkConfig; then
    echo -e "${GREEN}Done!\nrestart your shell to see the changes.${RC}"
else
    echo -e "${RED}Something went wrong!${RC}"
fi

if [[ `pacman -Q | grep -i "sxhkd"` ]]; then
    if ! [[ -d $HOME/.config/autostart ]]; then
        mkdir -p $HOME/.config/autostart
    fi

    if ! [[ -f $HOME/.config/autostart/sxhkd.desktop ]]; then
        touch $HOME/.config/autostart/sxhkd.desktop
    fi

    printf "[Desktop Entry]\nName=sxhkd\nComment=Simple X hotkey daemon\nExec=/usr/bin/sxhkd\nTerminal=false\nType=Application\n" | tee $HOME/.config/autostart/sxhkd.desktop

    if ! [[ -d $HOME/.config/sxhkd ]]; then
        mkdir -p $HOME/.config/sxhkd
    fi

    cp -f sxhkdrc $HOME/.config/sxhkd
fi

if [[ `pacman -Q | grep -i "wezterm"` ]]; then
    cp -f .wezterm.lua $HOME
fi

exit 0
