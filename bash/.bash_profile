# Import Tokens, Company Settings and etc.
source ~/.bash_secure
source ~/.bash_company

# Auto-completion
[[ $- == *i* ]] && source "/usr/local/opt/fzf/shell/completion.bash" 2> /dev/null

# FZF
if [[ ! "$PATH" == */usr/local/opt/fzf/bin* ]]; then
  export PATH="$PATH:/usr/local/opt/fzf/bin"

  fvim() {
    local IFS=$'\n'
    local files=($(fzf-tmux --query="$1" --multi --select-1 --exit-0))
    [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
  }
fi

# Key bindings
source "/usr/local/opt/fzf/shell/key-bindings.bash"
bind -x '"\C-p": fvim'

# BREW
export HOMEBREW_NO_INSTALL_CLEANUP=1

# GREP
alias grep="grep -I"

# Copy/Paste
alias clip="pbcopy"

# GO
export GOPATH="$HOME/src/go"
export PATH="$GOPATH/bin:$PATH"

# GIT
alias branch-cleanup='git branch --merged | egrep -v "(^\*|master|dev)" | xargs git branch -d'
parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
alias cdg="cd $(git rev-parse --show-toplevel)" # Change to Root of Repo

# VIM
alias vi="vim"
export EDITOR="vim"

# Terraform
alias tf="terraform"
export TF_CLI_ARGS_apply="-auto-approve=false"
export TF_CLI_ARGS_destroy="-auto-approve=false"
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"

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

# Eternal bash history.
export HISTFILESIZE=
export HISTSIZE=
export HISTTIMEFORMAT="[%F %T] "
export HISTCONTROL='ignorespace:ignoredups'
export HISTFILE=~/.bash_eternal_history
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

# Shell
export CLICOLOR=1
export PS1="\u@\h \[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ "

# FZF
bind -r "\C-j" #  unbind accept-line
bind -x '"\C-j": fjira'
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
