# Import Tokens, Company Settings and etc.
source ~/.bash_secure
source ~/.bash_company

# Auto-completion
[[ $- == *i* ]] && source "/usr/local/opt/fzf/shell/completion.bash" 2> /dev/null
[[ $- == *i* ]] && source "/usr/local/opt/fzf/shell/key-bindings.bash" 2> /dev/null

# FZF
if [[ ! "$PATH" == */usr/local/opt/fzf/bin* ]]; then
  export PATH="$PATH:/usr/local/opt/fzf/bin"
fi

fvim() {
  local IFS=$'\n'
  local FILES=$(
    fzf-tmux \
      --query="$1" \
      --multi \
      --select-1 \
      --exit-0)
  [[ -n "$FILES" ]] && ${EDITOR:-vim} "${FILES[@]}"
}
bind -x '"\C-p": fvim'

# BREW
export HOMEBREW_NO_INSTALL_CLEANUP=1

# GREP
alias grep="grep --binary-file=without-match"

# Formatting
alias clip="pbcopy"
strip_colors() {
  perl -pe 's/\[[0-9;]*[mGKF]//g'
}

# Reverse input
alias tac="sed '1!G;h;\$!d'"

# GO
export GOPATH="$HOME/src/go"
export PATH="$GOPATH/bin:$PATH"

# GIT
branch_cleanup() {
  git branch --merged |\
  egrep -v \
    "(^\*|master|dev)" |\
  xargs git branch -d
}

parse_git_branch() {
  git branch 2> /dev/null |\
  sed \
    -e '/^[^*]/d' \
    -e 's/* \(.*\)/ (\1)/'
}

# Change to Root of Repo
cdg() {
  cd $(git rev-parse --show-toplevel)
}

# VIM
alias vi="vim"
export EDITOR="vim"

# Terraform
alias tf="terraform"
export TF_CLI_ARGS_apply="-auto-approve=false"
export TF_CLI_ARGS_destroy="-auto-approve=false"
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
source ~/.bash_terraform

# Kubernets
fluxctl_ns() {
  fluxctl \
    --k8s-fwd-ns $(kubens -c) \
  $@
}

# Ansible
export ANSIBLE_HOST_KEY_CHECKING=False
export ANSIBLE_STDOUT_CALLBACK=debug

# Draw IO
drawio() {
  { /Applications/draw.io.app/Contents/MacOS/draw.io -c $@ & } 2> /dev/null
}

# Typora
typora() {
  if [ "$#" -eq 0 ]; then
    open -a typora .
  else
    open -a typora $@
  fi
}

# Ruby
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# Python
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
alias py="pipenv run python"

# Diff
unalias diff_sxs 2> /dev/null
diff_sxs() {
  diff \
  --width=$COLUMNS \
  --side-by-side \
  --color
}

# Find and Replace
regex_replace() {
  perl -p -i -e \
  "s|$1|$2|g"
}

find_replace() {
  # Single Line Match
  # Exclude dot files/folders
  perl -p -i -e "s|$1|$2|g" \
  $(find . -type f -not -path '*/\.*')
}
find_replace_string() {
  # File is String with \n as line return
  # Exclude dot files/folders
  # s == "dot matches new line"
  perl -0 -p -i -e "s|$1|$2|gs" \
  $(find . -type f -not -path '*/\.*')
}

# Eternal bash history.
export HISTFILESIZE=
export HISTSIZE=
export HISTTIMEFORMAT="[%F %T] "
export HISTCONTROL='ignorespace:ignoredups'
export HISTFILE=~/.bash_eternal_history
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

# Shell
export CLICOLOR=1
export PS1="\u@\h \[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\]  $ "

# FZF
# bind -r "\C-i" #  unbind accept-line
# bind -x '"\C-i": fjira'
fjira() {
  local IFS=$'\n'
  jira list \
    --query "project IN (${JIRA_PROJECTS}) AND resolution = unresolved AND status != Closed ORDER BY created" | \
  fzf-tmux \
    --query="$1" \
    --multi \
    --select-1 \
    --preview  "echo {} | cut -d ':' -f 1 |
      xargs -I % sh -c 'jira view %'" \
    --bind 'enter:execute/
      echo {} | cut -d ':' -f 1 |
      xargs -I % sh -c "jira edit % < /dev/tty"
      /' \
    --exit-0
}

# SSH
if [ ! -S ~/.ssh/ssh_auth_sock ]; then
  eval `ssh-agent`
  ln -sf "$SSH_AUTH_SOCK" ~/.ssh/ssh_auth_sock
fi
export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock
ssh-add -l > /dev/null || ssh-add

GITHUB_SSH_FINGERPRINT=$(ssh-keygen -E sha256 -lf ~/.ssh/GitHub)
if ! [[ $(ssh-add -l | grep "${GITHUB_SSH_FINGERPRINT}") ]]; then
  ssh-add -K ~/.ssh/GitHub
fi

BITBUCKET_SSH_FINGERPRINT=$(ssh-keygen -E sha256 -lf ~/.ssh/bitbucket)
if ! [[ $(ssh-add -l | grep "${BITBUCKET_SSH_FINGERPRINT}") ]]; then
  ssh-add -K ~/.ssh/bitbucket
fi
