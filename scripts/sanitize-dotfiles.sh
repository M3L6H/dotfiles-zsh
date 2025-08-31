#!/usr/bin/env bash

directory="$1"

find "$directory" -type f -print0 | while IFS= read -r -d '' f; do
    # Sanitize home directory
    perl -i -pe 's|/home/testUser|\${HOME}|g' "$f"
    # Sanitize executables
    perl -i -pe 's|/nix/store/.*/bin/||g' "$f"
    # Sanitize share directory
    perl -i -pe 's|/nix/store/.*/share/([^"/\n]+)|\$(dirname "\$(dirname "\$(which $1)")")/share/$1|g' "$f"
    # Remove hm-session-vars.sh
    perl -i -pe 's|^.*/hm-session-vars.sh.*$||' "$f"

    echo "Sanitized: ${f}"
done

echo "Sanitized all files in: ${directory}"
