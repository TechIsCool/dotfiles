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
