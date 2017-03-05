if [ -e .bashrc_local ]
then
    source .bashrc_local
fi

# Allow for work customizations
set -o emacs
set -b
set -o ignoreeof
set completion-ignore-case on

#
shopt -s cdspell checkwinsize cmdhist execfail histverify mailwarn no_empty_cmd_completion histappend gnu_errfmt histreedit extglob

# Clearly specific to the mac setup
case "$EEJ_PROFILE" in
    Home)
        source /usr/local/Cellar/git/2.10.0/etc/bash_completion.d/git-completion.bash
        source /usr/local/Cellar/git/2.10.0/etc/bash_completion.d/git-prompt.sh
        ;;
    *)
        echo "Unrecognized ARCH=${ARCH}"
        ;;
esac

## The notation \[ \] is used to tell bash that it presents as 0 onscreen chars
## \033[48;5;XYZm is a background color
## \033[38;5;XYZm is a foreground color

PS1='\[\033[48;5;19m\]\[\033[38;5;255m\]\[$(tput smul)\]\w\[$(tput rmul)\]$(__git_ps1) >\[\e[0m\] '
