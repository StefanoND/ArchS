# This is not a runnable script
#
# A cargo's config file may have a line throws errors every time when compiling with rust
# AKA "error: unknown codegen option: ` target-cpu`"
#
# Edit the config
sudo nano ~/.cargo/config
#
# Delete or comment this line
rustflags = ["-C target-cpu=native"]
