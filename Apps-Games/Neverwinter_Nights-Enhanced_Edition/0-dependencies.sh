#!/usr/bin/env bash

# Needed for dos2unix is needed to convert tlkedit to be usable in Linux  and the rest are dependencies for VS Code

PKGS=(
    'dos2unix'              # Needed to convert some Windows apps to Linux
    'clang'                 # Dependency for VSCode
    'lib32-clang'           # Dependency for VSCode
    'llvm'                  # Dependency for VSCode
    'llvm-libs'             # Dependency for VSCode
    'lib32-llvm'            # Dependency for VSCode
    'lib32-llvm-libs'       # Dependency for VSCode
)

for PKG in "${PKGS[@]}"; do
    if ! pacman -Q | grep -q ${PKG}; then
        echo
        echo "INSTALLING: ${PKG}"
        echo
        sudo pacman -S "$PKG" --noconfirm --needed
        echo
        sleep 1s
    fi
done

# It's already done if you followed Unreal Editor's instructions
if ! grep -q "DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1" /etc/environment; then
    echo
    echo "Enabling System Globalization Invariant to fix \"Couldn't find a valid ICU package\""
    echo
    export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
    printf "\nDOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1\n" | sudo tee -a /etc/environment
fi

# Restart VS Code after this if it's opened
