# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ---------------------------------
# oh-my-zsh base
# ---------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# load oh-my-zsh
plugins=(git)
source $ZSH/oh-my-zsh.sh

# ---------------------------------
# fix PATH (system + npm + pnpm)
# ---------------------------------
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.local/bin:$HOME/.npm-global/bin:$HOME/.local/share/pnpm:$PATH"

# ---------------------------------
# history settings
# ---------------------------------
HISTSIZE=5000
SAVEHIST=5000
HISTFILE=~/.zsh_history
setopt appendhistory sharehistory histignorealldups

# ---------------------------------
# completion tweaks
# ---------------------------------
autoload -Uz colors && colors
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

setopt correct        # command correction
setopt nobeep         # no terminal bell

# ---------------------------------
# generic aliases
# ---------------------------------
alias ll='ls -lah --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias dotfiles="code ~/uz6r/dotfiles"

# ---------------------------------
# pnpm shortcuts
# ---------------------------------
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

# ---------------------------------
# git shortcuts
# ---------------------------------
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

# ---------------------------------
# courtsite shortcuts
# ---------------------------------
alias compose="(cd ~/Courtsite/enjin && ./compose.sh)"
alias compose-stop="(cd ~/Courtsite/enjin && ./compose-stop.sh)"
alias compose-restart="(cd ~/Courtsite/enjin && ./compose-stop.sh && ./compose.sh)"

# ---------------------------------
# youtube / yt-dlp shortcuts
# ---------------------------------
# download best audio as mp3 in current dir
alias ytmp3='yt-dlp -x --audio-format mp3 --audio-quality 0'
# download best audio as mp3 and save to ~/Music
alias ytmp3m='yt-dlp -x --audio-format mp3 --audio-quality 0 -o "$HOME/Music/%(title)s.%(ext)s"'
# download best video+audio as mp4 in current dir
alias ytmp4='yt-dlp -f bestvideo+bestaudio --merge-output-format mp4'
# download playlist audio as mp3 into ~/Music
alias ytpl3='yt-dlp -x --audio-format mp3 --audio-quality 0 -o "$HOME/Music/%(playlist)s/%(title)s.%(ext)s"'
# download entire playlist video as mp4 into ~/Videos
alias ytpl4='yt-dlp -f bestvideo+bestaudio --merge-output-format mp4 -o "$HOME/Videos/%(playlist)s/%(title)s.%(ext)s"'


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ---------------------------------
# local overrides (machine-specific / secrets)
# ---------------------------------
if [ -f ~/.zshrc.local ]; then
  source ~/.zshrc.local
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
