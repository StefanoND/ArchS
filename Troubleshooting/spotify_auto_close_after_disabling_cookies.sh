# This is not a runnable script
#
#After disabling cookies in spotify is would automatically close
#Sometimes it would complain about not finding a GPU
#Sometimes it would complain about missing libs
#Going into its prefs
nano ~/.config/spotify/prefs
#
# And change this line from true
"app.cookies-disabled=true"
#
# to false
"app.cookies-disabled=false"
#
# Or just run the command below
sed -i "s|app.cookies-disabled=.*|app.cookies-disabled=false|g" $HOME/.config/spotify/prefs
