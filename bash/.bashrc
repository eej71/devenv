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

export LS_COLORS='rs=0:di=01;96:ln=01;95:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=05;40;37;41:mi=05;37;41:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;33:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.webp=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=01;36:*.au=01;36:*.flac=01;36:*.m4a=01;36:*.mid=01;36:*.midi=01;36:*.mka=01;36:*.mp3=01;36:*.mpc=01;36:*.ogg=01;36:*.ra=01;36:*.wav=01;36:*.oga=01;36:*.opus=01;36:*.spx=01;36:*.xspf=01;36:'

# macos?
#export PATH=${HOME}/.local/bin/:${PATH}

## The notation \[ \] is used to tell bash that it presents as 0 onscreen chars
## \033[48;5;XYZm is a background color
## \033[38;5;XYZm is a foreground color
PS1='\[\033[48;5;19m\]\[\033[38;5;255m\]\[$(tput smul)\]\w\[$(tput rmul)\]$(__git_ps1)\[\e[0m\] > '
export QT_GRAPHICSSYSTEM=native
