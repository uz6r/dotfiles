# ------------------------------
# fix PATH (system + npm + pnpm)
# ------------------------------
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.local/bin:$HOME/.npm-global/bin:$HOME/.local/share/pnpm:$PATH"

# ------------------------------
# colors & prompt
# ------------------------------
autoload -Uz colors && colors

HISTSIZE=5000
SAVEHIST=5000
HISTFILE=~/.zsh_history
setopt appendhistory sharehistory histignorealldups

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

PROMPT='%F{green}%n@%m%f %F{blue}%~%f %# '

setopt correct        # command correction
setopt nobeep         # no terminal bell

# ------------------------------
# generic aliases
# ------------------------------
alias ll='ls -lah --color=auto'
alias ..='cd ..'
alias ...='cd ../..'

# ------------------------------
# pnpm shortcuts
# ------------------------------
alias p="pnpm"
alias pi="pnpm install"
alias pr="pnpm run"

alias dev="pnpm start"
alias build="pnpm build:local"
alias build:dev="pnpm build:dev"
alias build:prod="pnpm build:prod"
alias serve="pnpm serve"
alias serve:cf="pnpm serve:cf-pages"

alias check="pnpm check"
alias lint="pnpm lint"
alias fmt="pnpm fmt"
alias ci="pnpm ci-check"

alias sm="pnpm slicemachine"
alias test="pnpm test"
alias footer="pnpm footer-gen"
alias ads="pnpm advertisement-gen"

# smart gql switch (detects which script exists in this repo)
gql() {
  if pnpm run | grep -q "gql-generate"; then
    pnpm gql-generate "$@"
  elif pnpm run | grep -q "gql-gen"; then
    pnpm gql-gen "$@"
  else
    echo "❌ no gql script found in this repo"
  fi
}

# ------------------------------
# git shortcuts
# ------------------------------
alias gs="git status"
alias ga="git add ."
alias gc="git commit -m"
alias gp="git push"
alias gl="git pull"
alias gco="git checkout"
alias gb="git branch"
alias gclean="git fetch -p && git branch -vv | awk '/: gone]/{print \$1}' | xargs git branch -d"

# create a new branch and push it upstream in one step
gpub() {
  if [ -z "$1" ]; then
    echo "❌ usage: gpub <branch-name>"
    return 1
  fi
  git checkout -b "$1" && git push -u origin "$1"
}

alias gm="git merge"
alias gr="git rebase"
alias gri="git rebase -i"
alias glog="git log --oneline --graph --decorate --all"

alias gst="git stash"
alias gstp="git stash pop"
alias gcp="git cherry-pick"
alias gfix="git commit --amend"

# ------------------------------
# courtsite shortcuts
# ------------------------------
alias compose="(cd ~/Courtsite/enjin && ./compose.sh)"
