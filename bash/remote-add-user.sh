#!/bin/bash

set -euo pipefail

HOST="${1:-}"
GECOS="${2:-}"
USERNAME="${3:-}"
GROUP="${4:-}"
PUBLICKEY="${5:-}"

# TODO: Use getopt.
OPTION_1="${6:-}"
OPTION_2="${7:-}"

function usage
{
  echo "Usage:" 2>&1
  echo "" 2>&1
  echo "  ${0} <host> <username> <userlogin> <usergroup> <key.pub> [--password-login] [--use-sudo]" 2>&1
  echo "" 2>&1
  echo "Example:" 2>&1
  echo "" 2>&1
  echo "  ${0} example.com 'Ivan Ivanov' ivan admin ./ivan_id_rsa.pub" 2>&1
  echo "" 2>&1
  exit 1
}

if [ -z "${HOST}" ]; then
  echo "Missing host" 2>&1
  usage
fi

if [ -z "${GECOS}" ]; then
  echo "Missing username" 2>&1
  usage
fi

if [ -z "${USERNAME}" ]; then
  echo "Missing userlogin" 2>&1
  usage
fi

if [ -z "${GROUP}" ]; then
  echo "Missing usergroup" 2>&1
  usage
fi

if [ ! -f "${PUBLICKEY}" ]; then
  if [ -z "${PUBLICKEY}" ]; then
    echo "Missing key.pub" 2>&1
  else
    echo "Missing key.pub file ${PUBLICKEY}" 2>&1
  fi
  usage
fi

PASSWORD_LOGIN=false
USE_SUDO=false

# TODO: Use getopt!
if [ "${OPTION_1}" == "--password-login" ]; then
  PASSWORD_LOGIN=true
else
  if [ "${OPTION_1}" == "--use-sudo" ]; then
    USE_SUDO=true
  else
    if [ ! -z "${OPTION_1}" ]; then
      echo "Unknown option ${OPTION_1}" 2>&1
      usage
    fi
  fi
fi

if [ "${OPTION_2}" == "--password-login" ]; then
  PASSWORD_LOGIN=true
else
  if [ "${OPTION_2}" == "--use-sudo" ]; then
    USE_SUDO=true
  else
    if [ ! -z "${OPTION_2}" ]; then
      echo "Unknown option ${OPTION_2}" 2>&1
      usage
    fi
  fi
fi

if [ "${PASSWORD_LOGIN}" == "true" ]; then
  SSH="ssh -oPubkeyAuthentication=no ${HOST}"
else
  SSH="ssh ${HOST}"
fi

COMMAND=" \
  adduser \
    --disabled-password \
    --gecos \"${GECOS}\" \
    --ingroup=${GROUP} \
    ${USERNAME} \
  && mkdir -p ~${USERNAME}/.ssh/ \
  && cat >~${USERNAME}/.ssh/authorized_keys \
  && chmod 700 ~${USERNAME}/.ssh/ \
  && chmod 600 ~${USERNAME}/.ssh/authorized_keys \
  && chown -R ${USERNAME} ~${USERNAME}/.ssh \
"

if [ "${USE_SUDO}" == "true" ]; then
  COMMAND="sudo bash -c '${COMMAND}'"
else
  COMMAND="bash -c '${COMMAND}'"
fi

${SSH} "${COMMAND}" < ${PUBLICKEY}
