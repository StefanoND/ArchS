#!/bin/sh
# flatpak vscodium wrapper for unreal editor

/usr/bin/flatpak run --branch=stable --arch=x86_64 --command=/app/bin/codium --file-forwarding com.vscodium.codium --no-sandbox --unity-launch --user-data-dir "${HOME}"/.config/VSCodium --extensions-dir /home/archuser/.vscode-oss/extensions "$@"
