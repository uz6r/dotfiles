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
HISTFILE="$HOME/.zsh_history"
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
alias dotfiles="code ${DOTFILES_DIR:-$HOME/uz6r/dotfiles}"
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
killport() {
  local pid=$(lsof -ti:$1)
  if [ -z "$pid" ]; then
    echo "no process found on port $1"
    return 0
  fi
  kill -9 $pid
  echo "killed process $pid on port $1"
}

localdev() {
  local base_dir="${COURTSITE_DIR:-$HOME/Courtsite}/enjin"
  dir1="$base_dir/enjin-proksi"
  dir2="$base_dir/enjin-pelanggan"
  dir3="$base_dir/enjin-konsol"
  dir4="$base_dir/enjin-core"
  dir5="$base_dir/enjin-setiausaha"
  dir6="$base_dir/enjin-workflow"
  
  start_tmux_layout() {
    tmux new-session "cd $dir1; exec zsh" \; \
      split-window -h "cd $dir2; exec zsh" \; \
      split-window -v "cd $dir3; exec zsh" \; \
      select-pane -t 0 \; \
      split-window -v "cd $dir4; exec zsh" \; \
      select-pane -t 1 \; \
      split-window -v "cd $dir5; exec zsh" \; \
      select-pane -t 2 \; \
      split-window -v "cd $dir6; exec zsh" \; \
      select-layout tiled
  }
  
  if [ -z "$TMUX" ]; then
    start_tmux_layout
  else
    tmux new-window
    start_tmux_layout
  fi
}


# ---------------------------------
# quick edits & system
# ---------------------------------
alias zshrc='${EDITOR:-code} "$HOME/.zshrc"'
alias reload='source "$HOME/.zshrc" && echo "✅ .zshrc reloaded"'
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
alias core="cd ${COURTSITE_DIR:-$HOME/Courtsite}/enjin/enjin-core"
alias konsol="cd ${COURTSITE_DIR:-$HOME/Courtsite}/enjin/enjin-konsol"
alias pelanggan="cd ${COURTSITE_DIR:-$HOME/Courtsite}/enjin/enjin-pelanggan"
alias proksi="cd ${COURTSITE_DIR:-$HOME/Courtsite}/enjin/enjin-proksi"
alias setiausaha="cd ${COURTSITE_DIR:-$HOME/Courtsite}/enjin/enjin-setiausaha"
alias sinar="cd ${COURTSITE_DIR:-$HOME/Courtsite}/enjin/sinar-client"
alias sinar-pi-setup="${DOTFILES_DIR:-$HOME/uz6r/dotfiles}/bin/sinar-pi-setup"
alias workflow="cd ${COURTSITE_DIR:-$HOME/Courtsite}/enjin/enjin-workflow"
alias infra="cd ${COURTSITE_DIR:-$HOME/Courtsite}/infrastructure"

alias compose="(cd ${COURTSITE_DIR:-$HOME/Courtsite}/enjin && ./compose.sh)"
alias compose-stop="(cd ${COURTSITE_DIR:-$HOME/Courtsite}/enjin && ./compose-stop.sh)"
alias compose-restart="(cd ${COURTSITE_DIR:-$HOME/Courtsite}/enjin && ./compose-stop.sh && ./compose.sh)"

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
[[ ! -f "$HOME/.p10k.zsh" ]] || source "$HOME/.p10k.zsh"

# ---------------------------------
# optional plugins (auto-load if installed)
# ---------------------------------
# Auto-suggestions
if [ -f "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  source "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# Syntax highlighting (must be loaded last)
if [ -f "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# fzf integration
[ -f "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# ---------------------------------
# nvm (optional - only load if installed)
# ---------------------------------
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  \. "$NVM_DIR/nvm.sh"
fi
if [ -s "$NVM_DIR/bash_completion" ]; then
  \. "$NVM_DIR/bash_completion"
fi

# ---------------------------------
# pnpm (auto-detect common installation paths)
# ---------------------------------
if command -v pnpm >/dev/null 2>&1; then
  # pnpm is already in PATH, nothing to do
  :
elif [ -n "$PNPM_HOME" ] && [ -d "$PNPM_HOME" ]; then
  # Use explicit PNPM_HOME if set
  case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
  esac
else
  # Try common installation locations
  for pnpm_path in \
    "$HOME/.local/share/pnpm" \
    "$HOME/.pnpm" \
    "$HOME/snap/code/current/.local/share/pnpm" \
    "$HOME/Library/pnpm"; do
    if [ -d "$pnpm_path" ]; then
      export PNPM_HOME="$pnpm_path"
      case ":$PATH:" in
        *":$PNPM_HOME:"*) ;;
        *) export PATH="$PNPM_HOME:$PATH" ;;
      esac
      break
    fi
  done
fi

# ---------------------------------
# local overrides (machine-specific / secrets)
# ---------------------------------
if [ -f "$HOME/.zshrc.local" ]; then
  source "$HOME/.zshrc.local"
fi