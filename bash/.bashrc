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

# Exit early for non-interactive shells
[[ $- == *i* ]] || return

# Nudge if local config is missing
[[ -x ~/devenv/check-local.sh ]] && ~/devenv/check-local.sh
# Git completion and prompt - search common locations
_git_completion_candidates=(
    /usr/share/doc/git/contrib/completion/git-completion.bash
    /usr/share/bash-completion/completions/git
    /usr/local/etc/bash_completion.d/git-completion.bash
    /opt/homebrew/etc/bash_completion.d/git-completion.bash
)
for _f in "${_git_completion_candidates[@]}"; do
    if [ -f "$_f" ]; then source "$_f"; break; fi
done

_git_prompt_candidates=(
    /usr/share/doc/git/contrib/completion/git-prompt.sh
    /usr/lib/git-core/git-sh-prompt
    /etc/bash_completion.d/git-prompt
    /usr/local/etc/bash_completion.d/git-prompt.sh
    /opt/homebrew/etc/bash_completion.d/git-prompt.sh
)
for _f in "${_git_prompt_candidates[@]}"; do
    if [ -f "$_f" ]; then source "$_f"; break; fi
done
unset _f _git_completion_candidates _git_prompt_candidates

# Specific domains
case "$EEJ_PROFILE" in
    Home)
        _ps1_bg="35;70;80"
        function ed { emacsclient -nw $@; }
        function ed { emacsclient -nw $@; }
        function xed { emacsclient -n -c $@ 2> /dev/null; }
        function ted { emacsclient -n -c $@ 2> /dev/null; }
        ;;

    Work)
        _ps1_bg="0;0;175"
        function ed { TERM=xterm-256color emacsclient -nw $@; }
        function xed { emacsclient -n -c --frame-parameters="((width . 170)(height . 40)(top . 10)(left . 10))" $@ 2> /dev/null; }
        function ted { emacsclient -n -c --frame-parameters="((width . 170)(height . 40)(top . 10)(left . 10))" $@ 2> /dev/null; }
        #xset r rate 350 60 # Defines the faster repeat rate for X11
        ;;

    *)
        echo "Unrecognized PROFILE=${EEJ_PROFILE}"
        ;;
esac
alias ls='ls --color=auto'
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

HISTCONTROL=ignoredups:erasedups
HISTIGNORE="&:ls:[bf]g:exit"
HISTTIMEFORMAT="%F %T  "
HISTSIZE=1000000
HISTFILESIZE=1000000

PROMPT_DIRTRIM=4
# Keep shell histories shared across concurrent sessions.
# - history -a: append this shell's new entries to $HISTFILE
# - history -n: read entries added by other shells
eej_history_sync() {
    builtin history -a
    builtin history -n
}

case ";${PROMPT_COMMAND};" in
    *";eej_history_sync;"*) ;;
    ";;") PROMPT_COMMAND="eej_history_sync" ;;
    *) PROMPT_COMMAND="eej_history_sync;${PROMPT_COMMAND}" ;;
esac

# Up/Down search history by current prefix, newest match first.
bind "\"\e[A\": history-search-backward"
bind "\"\e[B\": history-search-forward"
bind "\"\eOA\": history-search-backward"
bind "\"\eOB\": history-search-forward"

export PATH=~/tmux/:${PATH}
export PATH
export TERM=xterm-256color

export LS_COLORS='rs=0:di=01;96:ln=01;95:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=05;40;37;41:mi=05;37;41:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;33:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.webp=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=01;36:*.au=01;36:*.flac=01;36:*.m4a=01;36:*.mid=01;36:*.midi=01;36:*.mka=01;36:*.mp3=01;36:*.mpc=01;36:*.ogg=01;36:*.ra=01;36:*.wav=01;36:*.oga=01;36:*.opus=01;36:*.spx=01;36:*.xspf=01;36:'

# macos?
#export PATH=${HOME}/.local/bin/:${PATH}

## The notation \[ \] is used to tell bash that it presents as 0 onscreen chars
## \033[48;5;XYZm is a background color
## \033[38;5;XYZm is a foreground color
PS1="\[\033[48;2;${_ps1_bg}m\]\[\033[38;2;255;255;255m\]\h|\[$(tput smul)\]\w\[$(tput rmul)\]\$(__git_ps1)\[\e[0m\] > "
export QT_GRAPHICSSYSTEM=native

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Undo the silliness of any corporate proxy settings
unset HTTP_PROXY
unset HTTPS_PROXY
unset http_proxy
unset https_proxy
unset FTP_PROXY
unset ftp_proxy
export PATH="$HOME/.claude/bin:$HOME/.local/bin:$PATH"

# Flush stale terminal query responses (e.g. OSC 11) that tmux
# sends on session startup before the shell is ready.
[[ -n "$TMUX" ]] && { sleep 0.05; read -r -t 0.1 -d '' -n 10000 2>/dev/null; clear; }