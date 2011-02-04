#! /bin/bash

set -e

HOST="${1}"
GECOS="${2}"
USERNAME="${3}"
GROUP="${4}"
PUBLICKEY="${5}"

# TODO: Use getopt.
OPTION_1="${6}"
OPTION_2="${7}"

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
  && mkdir ~${USERNAME}/.ssh/ \
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
