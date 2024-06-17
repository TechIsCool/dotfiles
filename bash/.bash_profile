# Global Tools
log_command() { history -s ${@} && ${@} || return; }
export_path() { [[ ! "${PATH}" == *"${1}"* ]] && export PATH="${1}:${PATH}" || return; }

# Import Tokens, Company Settings and etc.
source ~/.bash_secure
source ~/.bash_company

# Auto-completion
[[ $- == *i* ]] && source "/usr/local/opt/fzf/shell/completion.bash" 2> /dev/null
[[ $- == *i* ]] && source "/usr/local/opt/fzf/shell/key-bindings.bash" 2> /dev/null

# FZF
export_path "/usr/local/opt/fzf/bin"

# VIM
export EDITOR='nvim'
alias vi="${EDITOR}"

zdd() {
  local DIR
  DIR=$(
    find "${1:-.}" -path '*/\.*' -prune -o -type d -print 2> /dev/null |\
      fzf +m \
        --preview='tree -C {} | head -n $FZF_PREVIEW_LINES' \
        --preview-window='right:hidden:wrap' \
        --bind=ctrl-v:toggle-preview \
        --bind=ctrl-x:toggle-sort \
        --header='(view:ctrl-v) (sort:ctrl-x)' \
    ) || return
  log_command cd "${DIR}"
}

fvim() {
  local IFS=$'\n'
  if [[ -f  ".terraform/modules/modules.json" ]]; then
    local CUSTOM_DIRS=$(
      cat '.terraform/modules/modules.json'  |\
      jq -r '.Modules[].Dir' | sort | uniq
    )
  fi

  local FILES=$(
    find ${CUSTOM_DIRS:-.} -not -path './.*' -type f -print 2> /dev/null |\
    fzf-tmux \
      --query="$1" \
      --multi \
      --select-1 \
      --exit-0)
  if [[ -n "${FILES}" ]]; then
    log_command ${EDITOR:-vim} ${FILES[@]}
  fi
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
export GOPATH="${HOME}/src/go"
export_path "${GOPATH}/bin"
export GODEBUG=asyncpreemptoff=1 # https://yaleman.org/post/2021/2021-01-01-apple-m1-terraform-and-golang/

# GIT
branch_cleanup() {
  git branch --merged |\
  egrep -v \
    "(^\*|master|dev)" |\
  xargs git branch -d
}

git_clone() {
  if [[ ! "${1}" == *"http"* ]]; then
    echo "Currently only http is supported"
    exit 10
  fi

  REPO=$(basename "${1}")
  ORG=$(basename $(dirname "${1}"))
  TLD=$(basename $(dirname $(dirname "${1}")))
  DOMAIN="${TLD/.*/}"
  DIR="${HOME}/src/${DOMAIN}/${ORG}/${REPO}"
  if [ -d "${DIR}" ]; then
    echo "Repo ${1} already exists at '${DIR}'"
  else
    mkdir -p "${DIR}"
    git clone "${1}" "${DIR}"
  fi
  cd ${DIR}
}

parse_git_branch() {
  git branch 2> /dev/null |\
  sed \
    -e '/^[^*]/d' \
    -e 's/* \(.*\)/ (\1)/'
}

# Change to Root of Repo
cdg() {
  log_command cd $(git rev-parse --show-toplevel)
}

# VIM
alias vi="vim"
export EDITOR="vim"

# Terraform
alias tf="terraform"
export TFENV_ARCH=arm64
export TF_CLI_ARGS_apply="-auto-approve=false"
export TF_CLI_ARGS_destroy="-auto-approve=false"
export TF_PLUGIN_CACHE_DIR="${HOME}/.terraform.d/plugin-cache"
source ~/.bash_terraform

# Kubernets
fluxctl_ns() {
  fluxctl \
    --k8s-fwd-ns $(kubens -c) \
  ${@}
}

# Ansible
export ANSIBLE_HOST_KEY_CHECKING=False
export ANSIBLE_STDOUT_CALLBACK=debug

# AWS
export export AWS_PAGER='less'
source ~/.bash_aws

get_me_creds() {
  aws sso get-role-credentials \
    --account-id $(aws configure get sso_account_id --profile ${AWS_PROFILE}) \
    --role-name $(aws configure get sso_role_name --profile ${AWS_PROFILE}) \
    --access-token $(find ~/.aws/sso/cache -type f ! -name "botocore*.json" | xargs jq -r .accessToken) \
    --region $(aws configure get region --profile ${AWS_PROFILE}) |\
  jq -r '.roleCredentials |
    {
      "AWS_ACCESS_KEY_ID": .accessKeyId,
      "AWS_SECRET_ACCESS_KEY": .secretAccessKey,
      "AWS_SESSION_TOKEN": .sessionToken,
      "AWS_CREDENTIALS_EXPIRATION": (.expiration / 1000 | todate)
    }
    | keys[] as $k
    | "export \($k)=\(.[$k])"
  '
}

# Draw IO
drawio() {
  { /Applications/draw.io.app/Contents/MacOS/draw.io -c ${@} & } 2> /dev/null
}

# Typora
typora() {
  if [ "${#}" -eq 0 ]; then
    open -a typora .
  else
    open -a typora ${@}
  fi
}

# Ruby
export_path "${HOME}/.rbenv/bin"

eval "$(rbenv init -)"

# Python
export PYENV_ROOT="${HOME}/.pyenv"
export_path "${PYENV_ROOT}/bin"
eval "$(pyenv init -)"
alias py="pipenv run python"

# Diff
unalias diff_sxs 2> /dev/null
diff_sxs() {
  diff \
  --width=${COLUMNS} \
  --side-by-side \
  --color ${@}
}

# Find and Replace
regex_replace() {
  perl -p -i -e \
    "s|${1}|${2}|g"
}

find_files() {
  # Exclude dot files/folders
  FILES=$( [ -t 0 ] || cat )
  if [[ "${FILES}" == "" ]]; then
    FILES=$(find "${1:-.}" -type f -not -path '*/\.*')
  fi
  echo "${FILES}" |\
  fzf \
    --multi \
    --bind "ctrl-a:toggle-all" \
    --header='(toggle-all:ctrl-a)'
}

find_replace() {
  # Single Line Match
  # Exclude dot files/folders
  FILES=$(find_files $@)
  [[ ${FILES} ]] && perl -p -i -e "s|${1}|${2}|g" ${FILES}
}

find_replace_string() {
  # File is String with \n as line return
  # Exclude dot files/folders
  # s == "dot matches new line"
  FILES=$(find_files $@)
  [[ ${FILES} ]] && perl -0 -p -i -e "s|${1}|${2}|gs" ${FILES}
}

aws_decode() {
  aws sts \
  decode-authorization-message \
  --encoded-message \
  ${@} |\
  jq -r '.DecodedMessage | fromjson' |\
  yq -P '.' -
}

# Eternal bash history.
export HISTFILESIZE=
export HISTSIZE=
export HISTTIMEFORMAT="[%F %T] "
export HISTCONTROL='ignorespace:ignoredups'
export HISTFILE=~/.bash_eternal_history
PROMPT_COMMAND="history -a; ${PROMPT_COMMAND}"

# Shell
export CLICOLOR=1
export PS1="\u@\h \[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\]  $ "

# Vault
vault_patch(){
  vault read \
    ${1} \
    -format=json |\
  jq .data |\
  vault write \
    ${1} \
    - \
    ${@:2}
}

# FZF
# bind -r "\C-i" #  unbind accept-line
# bind -x '"\C-i": fjira'
jira_ticket_id() { awk -F ':' '{print $1}'; }

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

# jq repl
# https://github.com/junegunn/dotfiles/blob/057ee47465e43aafbd20f4c8155487ef147e29ea/bashrc#L449-L463
fjq() {
  local TEMP QUERY
  TEMP=$(mktemp -t fjq)
  cat > "${TEMP}"
  QUERY=$(
    jq -C . "${TEMP}" |
      fzf \
      --reverse \
      --ansi \
      --prompt 'jq> ' --query '.' \
      --preview "set -x; jq -C {q} \"${TEMP}\"" \
      --header 'Press CTRL-Y to copy expression to the clipboard and quit' \
      --bind 'ctrl-y:execute-silent(echo -n {q} | pbcopy)+abort' \
      --print-query | head -1
  )
  [ -n "${QUERY}" ] && jq "${QUERY}" "${TEMP}"
}

# GitHub
alias hub='gh'

# SSH
if [ ! -S ~/.ssh/ssh_auth_sock ]; then
  eval `ssh-agent`
  ln -sf "${SSH_AUTH_SOCK}" ~/.ssh/ssh_auth_sock
fi
export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock
ssh-add -l > /dev/null || ssh-add

GITHUB_SSH_FINGERPRINT=$(ssh-keygen -E sha256 -lf ~/.ssh/GitHub)
if ! [[ $(ssh-add -l | grep "${GITHUB_SSH_FINGERPRINT}") ]]; then
  ssh-add --apple-use-keychain ~/.ssh/GitHub
fi

BITBUCKET_SSH_FINGERPRINT=$(ssh-keygen -E sha256 -lf ~/.ssh/bitbucket |cut -d' ' -f1-3,6 )
if ! [[ $(ssh-add -l | grep "${BITBUCKET_SSH_FINGERPRINT}") ]]; then
  ssh-add --apple-use-keychain ~/.ssh/bitbucket
fi
