# This is not a runnable script
#
# There are two ways to fix it
#
# The simplest one is by changing the shortcut to either "Meta + F1" or "Alt + F1"
# If neither works it's be cause a app you installed had modified it such as Latte
#
# Now we have to change plasma's config
cd ~
sudo nano .config/kwinrc
#
# Now we look for the ModifierOnlyShortcuts, replace anything in there with the line below
# If you installed latte or other app, the line would show "org.kde.latte...."
[ModifierOnlyShortcuts]
Meta=org.kde.plasmashell,/PlasmaShell,org.kde.PlasmaShell,activateLauncherMenu
#
# Now we need to apply these changes
qdbus org.kde.KWin /KWin reconfigure
#
# Done
