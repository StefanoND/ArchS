# This is not a runnable script file
#
# There's something that I've installed that messes up with the cursor's appearance.
#
# To remedy this, you change the index.theme file in /usr/share/icons/default
#
# And change the "Inherits=Adwaita" to your cursor
# If you've installed custom cursor you have to copy their folder from ~/.icons/Cursor to /usr/share/icons and type the folder name into the "Inherits=" section
Inherits=Cursor-name
#
# For the  size you'll have to add a line into ~/.Xresources file
Xcursor.size: XX
#
# And then run the xrdb command
xrdb ~/.Xresources
