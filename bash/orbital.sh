#!/bin/bash
set -m
# trap 'kill $(jobs -p | xargs)' SIGINT SIGHUP SIGTERM EXIT

# TODO: Find out if I can some return while a pipe is open with CAT
# Terraform returns a successful apply but cat doesn't let go of the pipe
# To let the subshell return which means the pid get killed

TMP_DIR=$( mktemp -d /tmp/orbital.XXXXXXXXXX )
echo "${TMP_DIR}"

for OBJ in $( find . -type d -depth 1 | fzf --multi | xargs basename ); do
  echo "${OBJ}" >> "${TMP_DIR}/jobs.txt"
  PIPE="${TMP_DIR}/${OBJ}.pipe"

  mkfifo ${PIPE}
  touch ${TMP_DIR}/${OBJ}.{stdout,stderr}

  (
    cd "${PWD}/${OBJ}"
    terraform init --upgrade
    echo "Running Terraform Apply for '${OBJ}'"
    cat "${PIPE}" | terraform apply
    rm -f "${TMP_DIR}/${OBJ}.pid" # TODO: Why don't we make it here without 'enter'
  ) \
  2> ${TMP_DIR}/${OBJ}.stderr \
  1> ${TMP_DIR}/${OBJ}.stdout \
  &
  echo "${!}" > "${TMP_DIR}/${OBJ}.pid"
done

cat "${TMP_DIR}/jobs.txt" | fzf \
  --disabled \
  --scrollbar \
  --bind "enter:execute(echo {q} > ${TMP_DIR}/{}.pipe)" \
  --preview "tail -f -n +1 ${TMP_DIR}/{}.std*" \
  --preview-window 'follow,up,90%'

for PID in $( find "${TMP_DIR}" -name '*.pid' | xargs cat ); do
  kill -1 -${PID}
done

rm -rf "${TMP_DIR}"
