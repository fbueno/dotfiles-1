setopt histignorealldups sharehistory

#############################
# Index:                    #
#   * Keybindings           #
#   * History               #
#   * Aliases               #
#   * Functions             #
#   * Environment Variables #
#   * Miscellaneous         #
#############################

###############
# Keybindings #
###############

# Vim keybindings in Zsh
bindkey -v
bindkey '\e[3~' delete-char
bindkey '^R' history-incremental-search-backward

# zsh-history-substring-search
zmodload zsh/terminfo
if [[ `uname` == 'Darwin' ]]; then
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
else
    bindkey "$terminfo[kcuu1]" history-substring-search-up
    bindkey "$terminfo[kcud1]" history-substring-search-down
fi
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

###########
# History #
###########

HISTSIZE=10000
SAVEHIST=$HISTSIZE
HISTFILE=~/.zsh_history

###########
# Aliases #
###########

# auto ls after cd
if [[ `uname` == 'Darwin' ]]; then
    cd() { builtin cd "$@" && ls -G }
    pushd() { builtin pushd "$@" && ls -G }
    popd() { builtin popd "$@" && ls -G }
else
    cd() { builtin cd "$@" && ls --color=auto }
    pushd() { builtin pushd "$@" && ls --color=auto }
    popd() { builtin popd "$@" && ls --color=auto }
fi

# Colors!
if [[ `uname` == 'Darwin' ]]; then
    alias ls='ls -G'
else
    alias ls='ls --color=auto'
fi
alias grep='grep --color=auto'
alias tree='tree -C'

# Make OS X a little more GNU-ish
if [[ `uname` == 'Darwin' ]]; then
    alias tailf='tail -f'
    alias updatedb='sudo /usr/libexec/locate.updatedb'
fi

# Package managers
alias sag='sudo apt-get'
if [[ `uname` == 'Darwin' ]]; then
    alias uu='brew update && brew upgrade'
else
    alias uu='sudo apt-get update && sudo apt-get upgrade'
fi

# Python
alias py=python3

# SSH
alias secs='ssh ajclisso@login.secs.oakland.edu'

# Quickly change environment variables for tailing the appropriate logs
alias uportal='export CATALINA_BASE=/home/ajclisso/uPortal/uPortaltomcat'
alias myportal='export CATALINA_BASE=/home/ajclisso/uPortal/myPortaltomcat'
alias picknetid='export CATALINA_BASE=/home/ajclisso/uPortal/picknetidtomcat'

# Quickly generate a new JSR-286 portlet
alias newportlet='mvn archetype:generate -DarchetypeGroupId=org.jasig.portlet.archetype -DarchetypeArtifactId=jsr286-archetype'

# tail catalina.out
alias cattail='CATALINA_BASE=/home/ajclisso/uPortal/uPortaltomcat && rainbowize tail -f $CATALINA_BASE/logs/catalina.out'

# Git
alias ga='git add '
alias gb='git branch '
alias gc='git commit'
alias gco='git checkout '
alias gd='git diff'
alias gh='git hist'
alias gf='git fetch'
alias gm='git merge'
alias gp='git push'
alias gpu='git pull'
alias gr='git reset'
alias grm='git rm'
alias gs='git status '

# Because ls -l is almost impossible to type on the Dvorak layout
alias ao='ls'
alias aoe='ls -l'
alias aou='ls -a'
alias aoeu='ls -la'

# Fix tmux colorscheme issues
alias tmux="TERM=screen-256color-bce tmux"

if [[ `uname` == 'Darwin' ]]; then
    alias night='diskutil eject External'
    alias morn='diskutil mountDisk External'
fi

#############
# Functions #
#############

# Quickly go to a directory
#
# Layout of command:
#     cd `find -maxdepth 5 ...
#
#     (excluded directories and files)
#
#     ... -type d -name $1 | head -1`
goto() {
    builtin cd `find ~ -maxdepth 5       \
                                         \
    ! -path '*/.*/*'                     \
    ! -path '*/uPortal/*'                \
    ! -path '*/tomcat/webapps/*'         \
    ! -path '*/uPortal/overlay/admin/*'  \
    ! -name '.*'                         \
                                         \
    -type d -name $1 | head -1`
}

# Make and cd into a dir
function mkcd() { mkdir -p $(pwd)/$@ && cd $(pwd)/$@ }

# "Copy" file to ~/.clipboard
function yank {
    touch ~/.clipboard
    for i in "$@"; do
      if [[ $i != /* ]]; then i=$PWD/$i; fi
      i=${i//\\/\\\\}; i=${i//$'\n'/$'\\\n'}
      printf '%s\n' "$i"
    done >> ~/.clipboard
}

# "Paste" file from ~/.clipboard
function put {
    while IFS= read src; do
      cp -Rp "$src" .
    done < ~/.clipboard
    rm ~/.clipboard
}

# Pretend "copy" was "cut"
function putrm {
    while IFS= read src; do
      mv "$src" .
    done < ~/.clipboard
    rm ~/.clipboard
}

# Minimalist git clone
function clone {
if [[ $@ == */* ]]; then
        repo=$@
        # truncate username / repo to username/repo
        repo=${repo/\ \/\ /\/}
        git clone git@github.com:${repo}
    else
        # No "/" found--assume it's my own repo
        git clone git@github.com:aclissold/$@
    fi
}

# Usage: build [(portlet)|uportal]
function build {
    cwd=$(pwd)
    builtin cd ~/uPortal/uPortal
    for arg in "$@"
    do
        if [[ $arg == "uportal" ]]; then
            tomcatman -stop uportal
            groovy -Dbuild.portlets.skip=true build.groovy &&
            tomcatman -start uportal
        elif [[ $arg == "init" ]]; then
            tomcatman -stop uportal
            groovy -Dbuild.ant.target="clean initportal" build.groovy &&
            tomcatman -start uportal
        elif [[ $arg == "portlets" ]]; then
            groovy -Dbuild.portal.skip=true build.groovy
        else
            groovy -Dbuild.target.portlet=$arg build.groovy
        fi
    done
    builtin cd $cwd
}

# Easily open files in Chrome
function chrome {
    for i in "$@"; do
        google-chrome $(pwd)/$i > /dev/null
    done
}

# Trash commands
function del {
    mv -i "$@" ~/.Trash/
}
function emptytrash {
    rm -rf ~/.Trash/*
}

# Grep through specific file extensions
function greptype {
    if [[ $# != 2 ]] then;
        # filetype should be "java", not ".java" or "*.java"
        echo 'Usage: greptype <filetype> <pattern>'
    else
        find . -type f -name "*.$1" -exec grep --color=auto "$2" {} + 2>/dev/null
    fi
}

# Magic Grep Part I: cd into directories where grep matches are found
function grepcd() {
    # Print the results of grep, with numbers prepended.
    grep --color=always -r "$@" | nl
    # if grep matched anything
    if [[ $(echo $pipestatus | awk '{print $1}') == 0 ]]; then
        # prompt for a number
        echo -n "Enter the number of the path to cd into (q quits): "
        read linenumber
        # if a number was entered
        if [[ -n $(echo $linenumber | grep '^[0-9]*$') ]]; then
            # cd to the path of the file that was preprended by number entered
            cd `grep -r $@ | sed "s/:.*//" | xargs echo | awk -v path=$linenumber '{print $path}' | xargs dirname`
        fi
    fi
}

# Magic Grep Part II: Vim into a grep match at the match's line number
function grepvim() {
    grep --color=always -rn "$@" | nl
    # if grep matched anything
    if [[ $(echo $pipestatus | awk '{print $1}') == 0 ]]; then
        # prompt for a number
        echo -n "Enter number of the file you want to edit (q quits): "
        read linenumber
        # if a number was entered
        if [[ -n $(echo $linenumber | grep '^[0-9]*$') ]]; then
            # open Vim to the match's position
            vim `grep -nr $@ | sed 's/ //g' | sed 's/:[^:+][^:].*/:/' | sed 's/:/ /g' | xargs echo | awk -v path=$linenumber '{print $(path*2-1) " +" $(path*2)}'`
        fi
    fi
}

#########################
# Environment Variables #
#########################
if [[ `uname` == 'Darwin' ]]; then
    export M2_HOME=/usr/local/mvn
    export PATH=$PATH:$HOME/.apportable/SDK/bin
    export XML_CATALOG_FILES=/usr/local/etc/xml/catalog # for asciidoc
else
    export M2_HOME=/home/ajclisso/uPortal/maven
    export JAVA_HOME=/usr/lib/jvm/default-java
    export PATH=$JAVA_HOME/bin:$PATH
fi
export M2=$M2_HOME/bin
export PATH=$M2:$PATH

export ANT_HOME=/home/ajclisso/uPortal/ant
export PATH=$PATH:$ANT_HOME/bin

export CATALINA_HOME=/home/ajclisso/uPortal/tomcat
export PATH=$PATH:$CATALINA_HOME

export GROOVY_HOME=/home/ajclisso/uPortal/groovy
export PATH=$PATH:$GROOVY_HOME/bin

export PGDATA=/opt/PostgreSQL/9.2/
export PATH=$PATH:$PGDATA/bin

export JAVA_OPTS='-server -XX:MaxPermSize=512m -Xms1024m -Xmx2048m'

export GOROOT=/usr/local/go
export GOPATH=$HOME/Code/Go
export MYGO=$HOME/Code/Go/src/github.com/aclissold
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
export PATH=$HOME/Code/Go/go_appengine:$PATH

export ANDROID_HOME=/usr/local/android/sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools

export PATH=$PATH:$HOME/Code/Scripts

export PATH=$PATH:$HOME/.play
export PATH=$PATH:$HOME/.rvm/bin

################
# Miscellaneous #
#################

# Set the prompt!
precmd() { PROMPT='%B%~%b$(git_super_status) ' }

# Enable Python interpreter tab-complete
export PYTHONSTARTUP=~/.pythonrc

# Default text editor
export EDITOR=/usr/bin/vim

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
# eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# Plugin sourcing (order matters for some)
if [[ `uname` == 'Darwin' ]]; then
    [[ -s `brew --prefix`/etc/autojump.sh ]] && source `brew --prefix`/etc/autojump.sh
else
    [[ -s $HOME/.autojump/etc/profile.d/autojump.sh ]] && source $HOME/.autojump/etc/profile.d/autojump.sh
    source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Famed Zsh autocompletion (also used with autojump)
autoload -Uz compinit
compinit -u

source ~/.zsh/zsh-history-substring-search.zsh
source ~/.zsh/git-prompt/zshrc.sh
source /usr/local/go/misc/zsh/go
