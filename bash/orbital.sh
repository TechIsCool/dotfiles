#!/bin/bash
#
# TODO: Check for required binaries without bash builtins
# terraform, fzf
set -m
[[ ${1} == "" ]] && COMMAND="plan" || COMMAND="${1}"

TMP_DIR=$(mktemp -d /tmp/orbital.XXXXXXXXXX)

for OBJ in $(find . -type f -name 'setup.tf' -print0 | xargs -0 dirname | sed -e "s/^\.\///g" | fzf --multi); do
  echo "${OBJ}" >>"${TMP_DIR}/jobs.txt"
  mkdir -p "${TMP_DIR}/${OBJ}"
  PIPE="${TMP_DIR}/${OBJ}.pipe"

  mkfifo "${PIPE}"
  touch "${TMP_DIR}/${OBJ}.{stdout,stderr}"

  (
     cd "${PWD}/${OBJ}" || { echo "Failed to move into '${PWD}/${OBJ}'"; exit 1; }
     terraform init --upgrade
     echo "Running Terraform '${COMMAND}' for '${OBJ}'"
     cat "${PIPE}" | terraform "${COMMAND}"
     rm -f "${TMP_DIR}/${OBJ}.pid" "${PIPE}"
     echo "Task Completed"
  ) \
     2>"${TMP_DIR}/${OBJ}.stderr" \
     1>"${TMP_DIR}/${OBJ}.stdout" \
     &

  echo "${!}" >"${TMP_DIR}/${OBJ}.pid"
done

cat "${TMP_DIR}/jobs.txt" | fzf \
  --disabled \
  --bind "enter:execute(echo {q} > ${TMP_DIR}/{}.pipe)" \
  --bind 'ctrl-/:toggle-search' \
  --preview "tail -f -n +1 ${TMP_DIR}/{}.stdout ${TMP_DIR}/{}.stderr" \
  --preview-window 'follow,up,90%'

for PIPE in $(find "${TMP_DIR}" -name '*.pipe'); do
  echo "Asking '${PIPE}' to exit gracefully"
  echo "" >"${PIPE}"
done

while [[ $(find "${TMP_DIR}" -name '*.pipe' | wc -l) -gt 0 ]]; do
  printf '.'
  sleep 1
done

for PID in $(find "${TMP_DIR}" -name '*.pid' -print0 | xargs -0 cat); do
  echo "Killing '${PID}' as it didn't gracefully exit in time"
  kill -1 -"${PID}" # we kill the process group since we are using subshells
done

rm -rf "${TMP_DIR}"
