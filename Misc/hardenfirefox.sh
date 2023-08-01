#!/usr/bin/env bash

if ! [ $EUID -ne 0 ]; then
    echo
    echo "Don't run this script as root."
    echo
    sleep 1s
    exit 1
fi

clear
echo
echo
echo "      _        _                                     ___                               "
echo "     / \   ___| |_ ___ _ __ _ __  _   _ _ __ ___    / _ \ _ __ ___   ___  __ _  __ _   "
echo "    / _ \ / _ \ __/ _ \ '__| '_ \| | | | '_ ' _ \  | | | | '_ ' _ \ / _ \/ _' |/ _' |  "
echo "   / ___ \  __/ ||  __/ |  | | | | |_| | | | | | | | |_| | | | | | |  __/ (_| | (_| |  "
echo "  /_/   \_\___|\__\___|_|  |_| |_|\__,_|_| |_| |_|  \___/|_| |_| |_|\___|\__, |\__,_|  "
echo "                                                                         |___/         "
echo "                                  Post-Install Script"
echo
echo
sleep 2s
clear

echo
echo
echo
echo "This is NOT a replacement for Tor Browser, don't use it as such!"
echo
echo "Press any key to continue"
echo
read ANYK

clear

sleep 1s

homepath=$HOME
hardenpath="$homepath"/.var/app/org.mozilla.firefox/.mozilla/firefox/*.harden

echo
echo "Open Firefox, in the address box, type \"about:profiles\", create a new profile, name it \"harden\" (all lower-case, no spaces, no numbers, no special characters)"
echo
echo "Press any key when you're done"
echo
read ANYKEY
while ! test -e $hardenpath; do
    echo
    echo "The \"harden\" profile could not be found"
    echo
    sleep 1s
done

if test -e $hardenpath; then
    cd $HOME

    if test -e $HOME/user.js; then
        rm -rf $HOME/user.js
    fi
    echo
    echo "Cloning Arkenfox's user.js for Firefox (Privacy and Security settings)"
    echo
    git clone https://github.com/arkenfox/user.js.git && cd user.js

    sleep 1s

    echo
    echo "Creating \"user-overrides.js\" file"
    echo
    if ! test -e $HOME/user.js/user-overrides.js; then
        touch $HOME/user.js/user-overrides.js
        sleep 1s
    fi
    echo
    printf "user_pref(\"geo.enabled\", false);\n" | tee $HOME/user.js/user-overrides.js
    printf "user_pref(\"media.webspeech.synth.enabled\", false);\n" | tee -a $HOME/user.js/user-overrides.js
    printf "user_pref(\"network.http.sendRefererHeader\", 0);\n" | tee -a $HOME/user.js/user-overrides.js
    printf "user_pref(\"webgl.disabled\", false);\n" | tee -a $HOME/user.js/user-overrides.js
    printf "user_pref(\"gfx.webrender.all\", true);\n" | tee -a $HOME/user.js/user-overrides.js
    printf "user_pref(\"gfx.webrender.enabled\", true);\n" | tee -a $HOME/user.js/user-overrides.js
    printf "user_pref(\"gfx.webrender.compositor\", true);\n" | tee -a $HOME/user.js/user-overrides.js
    printf "user_pref(\"gfx.webrender.compositor.force-enabled\", true);\n" | tee -a $HOME/user.js/user-overrides.js
    printf "user_pref(\"media.ffmpeg.vaapi.enabled\", true);\n" | tee -a $HOME/user.js/user-overrides.js
    #printf "\n" | tee -a $HOME/user.js/user-overrides.js
    echo

    sleep 1s

    sh $HOME/user.js/updater.sh
    echo
    echo "Copying files to Firefox's \"harden\" profile"
    echo
    cp -f *.* $hardenpath
    sleep 1s
    echo
    echo "Checking Hardening files"
    echo
    checkpass=0
    if test -e $hardenpath/_config.yml; then
        echo $checkpass
        checkpass=$((checkpass+1))
    fi
    if test -e $hardenpath/LICENSE.txt; then
        echo $checkpass
        checkpass=$((checkpass+1))
    fi
    if test -e $hardenpath/prefsCleaner.bat; then
        echo $checkpass
        checkpass=$((checkpass+1))
    fi
    if test -e $hardenpath/prefsCleaner.sh; then
        echo $checkpass
        checkpass=$((checkpass+1))
    fi
    if test -e $hardenpath/README.md; then
        echo $checkpass
        checkpass=$((checkpass+1))
    fi
    if test -e $hardenpath/updater.bat; then
        echo $checkpass
        checkpass=$((checkpass+1))
    fi
    if test -e $hardenpath/updater.sh; then
        echo $checkpass
        checkpass=$((checkpass+1))
    fi
    if test -e $hardenpath/user.js; then
        echo $checkpass
        checkpass=$((checkpass+1))
    fi
    if test -e $hardenpath/user-overrides.js; then
        echo $checkpass
        checkpass=$((checkpass+1))
    fi
    echo $checkpass
    if [[ ${checkpass,,} = 9 ]]; then
        echo
        echo "Hardening was applied successfully"
        echo
    fi
fi

echo
echo "Don't forget to run \"prefsCleaner.sh\" after changing firefox's settings"
echo
sleep 1s
echo
echo "If you're going to use Firefox's \"Sync\", only sync Bookmakrs, Add-ons and Settings, History and Open Tabs are optional"
echo "Leave \"Logins and passwrod\" and \"Credit Cards\" to a Manager App such as KeePassXC, BitWarden, etc"
echo
echo "Recommended extensions:"
echo "    uBlock Origin"
echo "    Decentraleyes"
echo "    bypass paywalls"
echo "        bypass paywalls link: https://github.com/iamadamdev/bypass-paywalls-chrome/releases/latest/download/bypass-paywalls-firefox.xpi"
echo
echo "Optional extensions:"
echo "    Youtube: Enhancer for YouTube"
echo "    Return YouTube Dislike"
echo "    SponsorBlock - Skip Sponsorships on YouTube"
echo
echo "Misc extensions:"
echo "    Jiffy Reader"
echo "    Dark Reader"
echo
echo "Also, you should use \"https://searx.thegpm.org/\" and/or \"https://search.brave.com/\" as search engines, use others as last resort"
echo
sleep 1s
echo
echo "You can now use firefox"
echo

exit 0
