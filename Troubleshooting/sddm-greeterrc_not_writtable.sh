# This is not a runnable script
#
# If you receive this error upon login:
#
# "Configuration file "/var/lib/sddm/.config/sddm-greeterrc" not writable.
# Please contact your system administrator."
#
# Run the following code
sudo chown sddm:sddm /var/lib/sddm/.config 
