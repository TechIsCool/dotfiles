export PATH="$HOME/.rbenv/bin:$HOME/src/go/bin:$PATH"

# Import Tokens, Company Settings and etc.
source ~/.bash_secure
source ~/.bash_company

# GO
export GOPATH="$HOME/src/go"

# GIT
alias branch-cleanup='git branch --merged | egrep -v "(^\*|master|dev)" | xargs git branch -d'
parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}


# VIM
alias vi="vim"
export EDITOR="vim"

# Terraform
alias tf="terraform"
export TF_CLI_ARGS_apply="-auto-approve=false"

# Shell
export CLICOLOR=1
export PS1="\u@\h \[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ "

# Eternal bash history.
# ---------------------
# Undocumented feature which sets the size to "unlimited".
# http://stackoverflow.com/questions/9457233/unlimited-bash-history
export HISTFILESIZE=
export HISTSIZE=
export HISTTIMEFORMAT="[%F %T] "
# Change the file location because certain bash sessions truncate .bash_history file upon close.
# http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
export HISTFILE=~/.bash_eternal_history
# Force prompt to write history after every command.
# http://superuser.com/questions/20900/bash-history-loss
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

# Default Typora to opening the cwd if you launch it from the CLI
typora() {
  if [ "$#" -eq 0 ]; then
    open -a typora .
  else
    open -a typora $@
  fi
}

export ANSIBLE_HOST_KEY_CHECKING=False

# Ruby
eval "$(rbenv init -)"

# SSH
if [ ! -S ~/.ssh/ssh_auth_sock ]; then
  eval `ssh-agent`
  ln -sf "$SSH_AUTH_SOCK" ~/.ssh/ssh_auth_sock
fi
export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock
ssh-add -l > /dev/null || ssh-add
