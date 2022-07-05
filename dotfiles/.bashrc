export VISUAL=vim
export EDITOR="$VISUAL"
export PATH=/home/isucon/isucon-setup/script:$PATH

alias mysqll='mysql -u isucon -p isucondition'
alias sbench='sudo /home/isucon/webapp/scripts/bench.sh'
alias gss='git status -s'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -v'
alias gca='git commit -v -a'
alias gcb='git checkout -b'
alias gcd='git checkout $(git_develop_branch)'
alias gcm='git checkout $(git_main_branch)'
alias gco='git checkout'
alias glgg='git log --graph'
alias gb='git branch'
alias gbD='git branch -D'
alias gba='git branch -a'
alias gbd='git branch -d'

__git_prompt_git () {
    GIT_OPTIONAL_LOCKS=0 command git "$@"
}

git_current_branch () {
    local ref
    ref=$(__git_prompt_git symbolic-ref --quiet HEAD 2> /dev/null)
    local ret=$?
    if [[ $ret != 0 ]]
    then
        [[ $ret == 128 ]] && return
        ref=$(__git_prompt_git rev-parse --short HEAD 2> /dev/null)  || return
    fi
    echo ${ref#refs/heads/}
}

ggu () {
    [[ "$#" != 1 ]] && local b="$(git_current_branch)"
    git pull --rebase origin "${b:=$1}"
}

ggp () {
    if [[ "$#" != 0 ]] && [[ "$#" != 1 ]]
    then
        git push origin "${*}"
    else
        [[ "$#" == 0 ]] && local b="$(git_current_branch)"
        git push origin "${b:=$1}"
    fi
}

alias ggpur='ggu'
