#!/usr/bin/env bash

directory="$1"
platform="$2"
arch="${platform%-*}"
os="${platform#*-}"

find "$directory" -type f -print0 | while IFS= read -r -d '' f; do
    chmod 666 "$f"

    # Sanitize home directory
    perl -i -pe 's|/home/testUser|\${HOME}|g' "$f"
    # Sanitize executables
    perl -i -pe 's|/nix/store/.*/bin/||g' "$f"
    # Sanitize share directory
    perl -i -pe 's|/nix/store/.*/share/([^"/\n]+)|\$(dirname "\$(dirname "\$(which $1)")")/share/$1|g' "$f"
    # Remove hm-session-vars.sh
    perl -i -pe 's|^.*/hm-session-vars.sh.*$||' "$f"

    # Move zoxide init to bottom
    if [ "$(basename "$f")" = '.zshrc' ]; then
        perl -i -pe 's|^.*zoxide init zsh.*$||g' "$f"
        echo 'eval "$(zoxide init zsh )"' >>"$f"
    fi

    if [ "$os" = 'darwin' ]; then
        # Copy/paste commands
        perl -i -pe 's|wl-copy|pbcopy|g' "$f"
        perl -i -pe 's|wl-paste|pbpaste|g' "$f"
    else
        # Auto suggestions
        perl -i -pe 's|^.*zsh-autosuggestions.*$||g' "$f"
        perl -i -pe 's|plugins=\((.*)\)|plugins=($1 zsh-autosuggestions)|g' "$f"
    fi

    echo "Sanitized: ${f}"
done && echo "Sanitized all files in: ${directory}"
