#!/bin/bash
# Stow all packages in ~/devenv into $HOME.
# Uses --restow to cleanly re-link (prune stale + re-stow).

cd "$(dirname "$0")" || exit 1

# Directories that are NOT stow packages
skip=(local local-templates terminal)

# Packages that need --no-folding because their target directory
# contains runtime state that shouldn't be replaced by a symlink
no_folding=(claude)

for dir in */; do
    dir="${dir%/}"

    # Skip non-packages
    for s in "${skip[@]}"; do
        [[ "$dir" == "$s" ]] && continue 2
    done

    opts=(--restow)
    for nf in "${no_folding[@]}"; do
        [[ "$dir" == "$nf" ]] && opts+=(--no-folding) && break
    done

    echo "stow: $dir"
    stow "${opts[@]}" "$dir"
done
