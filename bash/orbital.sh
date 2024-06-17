#!/bin/bash
# shellcheck disable=SC2002,SC2016
# TODO:
#  - If we are going to support passing a custom COMMAND; We should prompt the user
#    before running the action COMMAND="are you sure?; ${COMMAND}
#  - Find assumes 'setup.tf' exists but to normalize this command we should remove that filter
#  - We should probably add a timeout to the fzf command so that we don't wait forever
#  - FZF supports updating the query, maybe we can provide status on these jobs.
#    - Thinking about this something like [Plan] 'top/operations' and then it could be
#      updated to [Waiting] 'top/operations'. etc This might add to much complexity
#      but it really could add some fast visability while scrolling around. We could
#      event have something like [Exited] 'top/operations'
set -m

INPUT_COMMAND="${1}"
[[ "${INPUT_COMMAND}" == 'plan' ]] && COMMAND='cd "${WORKSPACE}"; terraform init --upgrade; terraform plan;'
[[ "${INPUT_COMMAND}" == 'apply' ]] && COMMAND='cd "${WORKSPACE}"; terraform init --upgrade; terraform apply;'
[[ "${COMMAND}" == '' ]] && { echo 'Currently only "plan" and "apply" are supported'; exit 1; }
[[ ! $(command -v fzf) ]] && { echo 'You do not have fzf installed.'; exit 1; }

STDIN=$( [ -t 0 ] || cat )
[[ "${STDIN}" == "" ]] && \
  STDIN=$(find . -type f -name 'setup.tf' -print0 | xargs -0 dirname | sed -e "s/^\.\///g")

TMP_DIR=$(mktemp -d /tmp/orbital.XXXXXXXXXX)

for OBJ in $( echo "${STDIN}" | fzf --multi ); do
  echo "${OBJ}" >>"${TMP_DIR}/jobs.txt"
  mkdir -p "${TMP_DIR}/${OBJ}"
  PIPE="${TMP_DIR}/${OBJ}.pipe"

  mkfifo "${PIPE}"
  touch "${TMP_DIR}/${OBJ}.{stdout,stderr}"

  (
    WORKSPACE="${PWD}/${OBJ}"
    echo "Running '${COMMAND}' for '${OBJ}'"
    cat "${PIPE}" | eval "${COMMAND}"
    rm -f "${TMP_DIR}/${OBJ}.pid" "${PIPE}"
    echo 'Task Completed'
  ) \
    2> "${TMP_DIR}/${OBJ}.stderr" \
    1> "${TMP_DIR}/${OBJ}.stdout" \
    &
  echo "${!}" >"${TMP_DIR}/${OBJ}.pid"
done

cat "${TMP_DIR}/jobs.txt" | fzf \
  --disabled \
  --bind "enter:execute(echo {q} > ${TMP_DIR}/{}.pipe)" \
  --bind 'ctrl-/:toggle-search' \
  --preview "tail -f -n +1 ${TMP_DIR}/{}.stdout ${TMP_DIR}/{}.stderr" \
  --preview-window 'follow,up,90%'

trap 'kill_processes' SIGINT
kill_processes() {
  for PID in $(find "${TMP_DIR}" -name '*.pid' -print0 | xargs -0 cat); do
    echo "Killing '${PID}' as it didn't gracefully exit"
    kill -1 -"${PID}" # we kill the process group since we are using subshells
  done
}

for PIPE in $(find "${TMP_DIR}" -name '*.pipe'); do
  echo "Asking '${PIPE}' to exit gracefully"
  echo '' >"${PIPE}"
done

while [[ $(find "${TMP_DIR}" -name '*.pipe' | wc -l) -gt 0 ]]; do
  printf '.'
  sleep 1
done

rm -rf "${TMP_DIR}"
