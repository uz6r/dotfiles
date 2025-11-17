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
plugins=(
  git
  sudo
  web-search
  copyfile
  copybuffer
  dirhistory
)
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
# shell behavior
# ---------------------------------
autoload -Uz colors && colors
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

setopt correct        # command correction
setopt nobeep         # no terminal bell
setopt autocd         # just type directory name to cd
setopt autopushd      # make cd push old dir onto stack
setopt pushdignoredups # don't push duplicates

# ---------------------------------
# generic aliases
# ---------------------------------
alias ll='ls -lah --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias dotfiles="code ~/uz6r/dotfiles"
alias c.="code ."

# directory stack navigation
alias d='dirs -v'
for i in {1..9}; do alias "$i"="cd +$i"; done

# safer file operations
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# find and grep helpers
alias ff='find . -type f -name'
alias fd='find . -type d -name'
alias grep='grep --color=auto'

# disk usage
alias duh='du -h --max-depth=1 | sort -hr'
alias df='df -h'

# ---------------------------------
# utility functions
# ---------------------------------
# make directory and cd into it
mkcd() { mkdir -p "$1" && cd "$1"; }

# backup a file
bak() { cp "$1"{,.bak}; }

# kill process on port
killport() { lsof -ti:$1 | xargs kill -9 }

localdev() {
  dir1="~/Courtsite/enjin/enjin-proksi"
  dir2="~/Courtsite/enjin/enjin-pelanggan"
  dir3="~/Courtsite/enjin/enjin-konsol"
  dir4="~/Courtsite/enjin/enjin-core"

  if [ -z "$TMUX" ]; then
    tmux new-session "cd $dir1; exec zsh" \; \
      split-window -h "cd $dir2; exec zsh" \; \
      split-window -v "cd $dir3; exec zsh" \; \
      select-pane -t 0 \; \
      split-window -v "cd $dir4; exec zsh" \; \
      select-layout tiled
  else
    tmux new-window "cd $dir1; exec zsh" \; \
      split-window -h "cd $dir2; exec zsh" \; \
      split-window -v "cd $dir3; exec zsh" \; \
      select-pane -t 0 \; \
      split-window -v "cd $dir4; exec zsh" \; \
      select-layout tiled
  fi
}


# ---------------------------------
# quick edits & system
# ---------------------------------
alias zshrc='${EDITOR:-code} ~/.zshrc'
alias reload='source ~/.zshrc && echo "✅ .zshrc reloaded"'
alias myip='curl -s ifconfig.me && echo'
alias localip='ip addr show | grep "inet " | grep -v 127.0.0.1'
alias ports='netstat -tulanp'

# clipboard (Linux)
alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'

# ---------------------------------
# pnpm shortcuts
# ---------------------------------
alias p="pnpm"
alias pi="pnpm install"
alias pr="pnpm run"
alias ni='pnpm install --frozen-lockfile'
alias nuke='rm -rf node_modules package-lock.json && pnpm install'
alias outdated='pnpm outdated'

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
alias gaa="git add --all"
alias gc="git commit -m"
alias gca="git commit --amend --no-edit"
alias gp="git push"
alias gpo="git push origin"
alias gl="git pull"
alias gpl="git pull origin"
alias gco="git checkout"
alias gb="git branch"
alias gd="git diff"
alias gds="git diff --staged"
alias gclean="git fetch -p && git branch -vv | awk '/: gone]/{print \$1}' | xargs git branch -d"

# create a new branch and push it upstream in one step
gpub() {
  if [ -z "$1" ]; then
    echo "❌ usage: gpub <branch-name>"
    return 1
  fi
  git checkout -b "$1" && git push -u origin "$1"
}

# switch to main/master branch
gmain() {
  git checkout $(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
}

alias gm="git merge"
alias gr="git rebase"
alias gri="git rebase -i"
alias glog="git log --oneline --graph --decorate --all"

alias gst="git stash"
alias gstp="git stash pop"
alias gcp="git cherry-pick"
alias gfix="git commit --amend"
alias grh="git reset --hard"
alias grs="git reset --soft HEAD~1"
alias gwip="git add . && git commit -m 'WIP'"
alias gunwip="git log -1 | grep -q 'WIP' && git reset HEAD~1"

# ---------------------------------
# docker shortcuts
# ---------------------------------
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dlog='docker logs -f'

# ---------------------------------
# courtsite shortcuts
# ---------------------------------
# cd into folder
alias core="cd ~/Courtsite/enjin/enjin-core"
alias konsol="cd ~/Courtsite/enjin/enjin-konsol"
alias pelanggan="cd ~/Courtsite/enjin/enjin-pelanggan"
alias proksi="cd ~/Courtsite/enjin/enjin-proksi"
alias setiausaha="cd ~/Courtsite/enjin/enjin-setiausaha"
alias workflow="cd ~/Courtsite/enjin/enjin-workflow"
alias infra="cd ~/Courtsite/infrastructure"

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

# ---------------------------------
# powerlevel10k
# ---------------------------------
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ---------------------------------
# optional plugins (uncomment to enable)
# ---------------------------------
# Auto-suggestions (install: git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions)
# Then add 'zsh-autosuggestions' to plugins array above

# Syntax highlighting (install: git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting)
# Then add 'zsh-syntax-highlighting' to plugins array above

# fzf integration
# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# ---------------------------------
# nvm
# ---------------------------------
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# ---------------------------------
# pnpm
# ---------------------------------
export PNPM_HOME="/home/uzer/snap/code/208/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# ---------------------------------
# local overrides (machine-specific / secrets)
# ---------------------------------
if [ -f ~/.zshrc.local ]; then
  source ~/.zshrc.local
fi