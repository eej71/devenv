# -*-sh-*-
# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi
# Source local settings
if [ -e ~/.bashrc_local ]
then
    source ~/.bashrc_local
fi

# Common bash settings
set -o emacs
set -b
set -o ignoreeof
set completion-ignore-case on
shopt -s cdspell checkwinsize cmdhist execfail histverify mailwarn no_empty_cmd_completion histappend gnu_errfmt histreedit extglob

# A primative way to see if there is no shell
if [ -z "$PS1" ]; then
    return
fi
# Specific domains
case "$EEJ_PROFILE" in
    Home)
        source /usr/share/doc/git/contrib/completion/git-completion.bash
        source /usr/share/doc/git/contrib/completion/git-prompt.sh
        function ed { emacsclient -nw $@; }
        #macos
        #source /usr/local/Cellar/git/2.10.0/etc/bash_completion.d/git-completion.bash
        #source /usr/local/Cellar/git/2.10.0/etc/bash_completion.d/git-prompt.sh
        function ed { emacsclient -nw $@; }
        function xed { emacsclient -n -c $@ 2> /dev/null; }
        function ted { emacsclient -n -c $@ 2> /dev/null; }
        ;;

    Work)
        alias ls='ls --color=auto'
        source /usr/share/doc/git/contrib/completion/git-completion.bash
        source /usr/share/doc/git/contrib/completion/git-prompt.sh
        function ed { TERM=xterm-256color emacsclient -nw $@; }
        function xed { emacsclient -n -c --frame-parameters="((width . 170)(height . 40)(top . 10)(left . 10))" $@ 2> /dev/null; }
        function ted { emacsclient -n -c --frame-parameters="((width . 170)(height . 40)(top . 10)(left . 10))" $@ 2> /dev/null; }
        xset r rate 350 60 # Defines the faster repeat rate for X11
        ;;

    *)
        echo "Unrecognized PROFILE=${EEJ_PROFILE}"
        ;;
esac
alias ll="ls -lAXF --color=auto --block-size=512 --time-style=long-iso"
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias cd..="cd .."

LD_LIBRARY_PATH=./:${LD_LIBRARY_PATH}
export TERM=xterm-256color
export LD_LIBRARY_PATH
export EDITOR='emacsclient -nw'
export VISUAL='emacsclient -nw'

# This is required for tree-sitter
LD_LIBRARY_PATH=/usr/local/lib/:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH
export HISTCONTROL=erasedups
export HISTIGNORE="&:ls:[bf]g:exit"
export HISTSIZE=100000
export HISTFILESIZE=100000
export PROMPT_DIRTRIM=4
export PROMPT_COMMAND="history -a ; history -c ; history -r; $PROMPT_COMMAND"
export PATH=~/tmux/:~/cgdb/cgdb/:$PATH
export PATH
export TERM=xterm-256color

# macos?
#export PATH=${HOME}/.local/bin/:${PATH}

## The notation \[ \] is used to tell bash that it presents as 0 onscreen chars
## \033[48;5;XYZm is a background color
## \033[38;5;XYZm is a foreground color
PS1='\[\033[48;5;19m\]\[\033[38;5;255m\]\[$(tput smul)\]\w\[$(tput rmul)\]$(__git_ps1) >\[\e[0m\] '
ulimit -c 0
export QT_GRAPHICSSYSTEM=native
