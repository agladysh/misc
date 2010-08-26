#! /bin/bash

set -e

HOST="${1}"
GECOS="${2}"
USERNAME="${3}"
GROUP="${4}"
PUBLICKEY="${5}"

function usage
{
  echo "Usage:" 2>&1
  echo "" 2>&1
  echo "  ${0} <host> <username> <userlogin> <usergroup> <key.pub>" 2>&1
  echo "" 2>&1
  echo "Example:" 2>&1
  echo "  ${0} example.com 'Ivan Ivanov' ivan admin ./ivan_id_rsa.pub" 2>&1
  echo "" 2>&1
  exit 1
}

if [ -z "${HOST}" ]; then
  usage
fi

if [ -z "${GECOS}" ]; then
  usage
fi

if [ -z "${USERNAME}" ]; then
  usage
fi

if [ -z "${GROUP}" ]; then
  usage
fi

if [ ! -f "${PUBLICKEY}" ]; then
  usage
fi

SSH="ssh ${HOST}"
COMMAND=" \
  adduser \
    --disabled-password \
    --gecos \"${GECOS}\" \
    --ingroup=${GROUP} \
    ${USERNAME} \
  && mkdir ~${USERNAME}/.ssh/ \
  && cat >~${USERNAME}/.ssh/authorized_keys \
  && chmod 700 ~${USERNAME}/.ssh/ \
  && chmod 600 ~${USERNAME}/.ssh/authorized_keys \
  && chown -R ${USERNAME} ~${USERNAME}/.ssh \
"

${SSH} "bash -c '${COMMAND}'" < ${PUBLICKEY}
