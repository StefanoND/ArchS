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

sleep 1s

echo
echo "You need access to Epic Game's Unreal Engine GitHub repository follow the instructions in the link bellow"
echo "https://www.unrealengine.com/en-US/ue-on-github"
echo
echo "When you're done go to \"https://github.com/EpicGames/UnrealEngine\", click on \"Fork\", leave everything as is and click \"Create fork\""
echo
sleep 1s
echo
echo "Press any key when you're done"
echo
read ANYKEY

export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
export SSL_CERT_DIR=/dev/null

echo
echo "Setup SSH key"
echo
sleep 1s

gitmail=null
gitmailanswer=n
while [[ ${gitmailanswer,,} = n ]]; do
    echo
    echo "What's your GitHub e-mail?"
    echo
    read GHMAIL
    gitmail=$GHMAIL
    echo
    echo "Is \"$gitmail\" correct?"
    echo
    read CONFIRMMAIL
    if [[ ${CONFIRMMAIL,,} = y ]]; then
        gitmailanswer=y
        sleep 1s
    fi
done

echo
echo "When asked \"Enter file in which to save the key\" just press \"Enter\" to save in default location (which is $HOME/.ssh/id_ed25519)"
echo
echo "Create a password when asked"
echo
ssh-keygen -t ed25519 -C $gitmail

echo
echo "Checking if ssh agent is running, if it returns \"Agent pid XXXX\", it's working"
echo
if sh -c 'ps -p $$ -o ppid=' | xargs -I'{}' readlink -f '/proc/{}/exe' | grep fish; then
    eval (ssh-agent -c)
    sleep 1s
else
    eval $(ssh-agent -s)
    sleep 1s
fi

echo
echo "If ssh agent is working, press any key to continue, if not, search online to make sure it's working before continuing"
echo
read SSHCONT

sleep 1s

clear

echo
echo
echo
cat $HOME/.ssh/id_ed25519.pub
sleep 1s
echo
echo "Copy the entire string above (from \"ssh-ed25519\" all the way to \"$gitmail\")"
echo
echo "Open your browser and go to your \"https://github.com/settings/keys\" page and click on \"New SSH key\""
echo
echo "Title: whatever you want, for simplicity I named mine \"epicgamesauth\""
echo "Key Type: Authentication Key"
echo "Key: Paste the string copied above in there"
echo
echo "Now click on \"Add SSH key\", you may need to confirm the operation if you have 2FA"
echo

sleep 1s

echo
echo "Press any key when you're done"
echo
read ANYKEYTWO
sleep 1s

#echo
#echo "Now let's create a (Fine-grained) Personal Access Token"
#echo
#echo "Open your browser and go to \"https://github.com/settings/tokens\" and click on \"Generate new token (Beta)\""
#echo
#echo "Token name: Whatever you want, for simplicity I named mine \"epicgamesdl\""
#echo "Expiration: 7 Days (For simplicity sake. If you want, you can set a custom one for just 1 day)"
#echo "Description: Irrelevant"
#echo
#echo "Repository access: Only selected repositories - \"USERNAME/UnrealEngine\""
#echo
#echo "Permissions"
#echo "    Repository permissions"
#echo "        Contents: Read-only"
#echo
#echo "Click on \"Generate token\""
#echo
#echo "COPY THE GENERATED CODE AS IT WON'T BE SHOWN AGAIN"

ueinstallpath=null
ueinstallanswer=n
echo
echo "Now it's time to download and install Unreal Engine"
echo
while [[ ${ueinstallanswer,,} = n ]]; do
    echo
    echo "Where do you want to install it? It's recommended to install it on an external drive"
    echo "We'll add \"Unreal_Engine5_2\" folder automatically"
    echo
    read INSTALLPATH
    ueinstallpath=$INSTALLPATH
    sleep 1s
    if test -e $ueinstallpath; then
        echo
        echo "Is \"$ueinstallpath\" correct?"
        echo
        read INSTALLCONFIRM
        if [[ ${INSTALLCONFIRM,,} = y ]]; then
            ueinstallanswer=y
            sleep 1s
        fi
    else
        echo
        echo "Path doesn't exist"
        echo
    fi
done


cpath=`pwd`
touch uepath.txt
printf "$ueinstallpath/UnrealEngine5_2" | tee uepath.txt

cd $ueinstallpath
gclonelink=null
gcloneanswer=n

echo
echo "Now go to your forked reposiroty of UnrealEngine and click on \"Code\" then \"SSH\" copy the link (will look like this git@github.com:USERNAME/UnrealEngine.git)"
echo
while [[ ${gcloneanswer,,} = n ]]; do
    echo
    echo "Now paste the link here:"
    read GITCLONE
    gclonelink=$GITCLONE
    sleep 1s
    echo
    echo "Is \"$gclonelink\" correct? Y - Yes | Anything else - No"
    echo
    read GCLONECONFIRM
    if [[ ${GCLONECONFIRM,,} = y ]]
        gcloneanswer=y
    fi
done
echo
echo "Now we'll download the repo"
echo
sleep 1s
echo
echo "It'll ask for the passphrase you used when creating the ssh key"
echo
sleep 1s
echo
echo "Wait for the download, around 18.62 GiB size (As of version 5.2.1)"
echo
git clone $gclonelink UnrealEngine5_2 && cd UnrealEngine5_2
sleep 1s
echo
echo "Making .sh scripts runnables"
echo
chmod +x *.sh
sleep 1s
echo
echo "Running \"Setup.sh\""
echo
sudo ./Setup.sh
sleep 1s
echo
echo "Running \"GenerateProjectFiles.sh\""
echo
sudo ./GenerateProjectFiles.sh
sleep 1s
echo
echo "Done"
echo
sleep 1s
echo
echo "The next part will take a very long time, and will be placed in the next script \"3-installue.sh\""
echo
sleep 1s
exit 0
