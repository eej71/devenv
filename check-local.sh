#!/bin/bash
# Checks that expected local config files exist.
# Add new entries to the list below as needed.

# Format: "template_name|target_path|description"
_local_checks=(
    "bashrc_local|$HOME/.bashrc_local|Shell profile/env vars (EEJ_PROFILE, API keys)"
    "gitconfig|$HOME/devenv/local/gitconfig|Git user name and email"
    "local-config.el|$HOME/devenv/local/local-config.el|Emacs machine-specific config"
    "claude-settings.json|$HOME/.claude/settings.json|Claude Code settings and permissions"
)

_missing=()
for _entry in "${_local_checks[@]}"; do
    IFS='|' read -r _name _target _desc <<< "$_entry"
    if [[ ! -f "$_target" ]]; then
        _template="$HOME/devenv/local-templates/${_name}.example"
        _missing+=("  $_desc")
        _missing+=("    missing:   $_target")
        if [[ -f "$_template" ]]; then
            _missing+=("    template:  $_template")
        fi
        _missing+=("")
    fi
done

if [[ ${#_missing[@]} -gt 0 ]]; then
    echo ""
    echo "Local config not set up:"
    echo ""
    printf '%s\n' "${_missing[@]}"
fi

unset _local_checks _missing _entry _name _target _desc _template
