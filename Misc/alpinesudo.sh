# This is not a runnable script file
#
# Using Alpine Linux you'll need to add the user to sudo
# To do that run the "su" command
su
# Add your root password
#
# Then edit visudo
EDITOR=vi visudo
#
# Use "j" and "k" keys or "Page Up" and "Page Down" keys to navigate up and down
# To edit, press "Insert" to go into "Insert" mode and type the changes, when you're done press "ESC" to go back to command mode
#
# In "## User privilege specification"
# Under "root ALL=(ALL:ALL) ALL" add "USERNAME ALL=(ALL:ALL) ALL" where USERNAME is the username you want to be sudo
USERNAME ALL=(ALL:ALL) ALL
#
# In "## Uncomment to allow members of group sudo to execute any command"
# Look for "#%sudo ALL=(ALL:ALL) ALL" and uncomment it
%sudo ALL=(ALL:ALL) ALL
#
# In command mode type ":w" to save and ":q" to quit. You can type ":q!" to quit without saving
# Save and exit.
#
# Done
