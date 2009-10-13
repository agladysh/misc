#! /bin/bash
if [ ! `id -u` -eq 0 ]; then
  echo "Superuser privileges required" 1>&2
  exit 1
fi

NAME=$1
if [ -z "${NAME}" ]; then
  echo "Usage: ./new.sh <repo-name>" 1>&2
  exit 2
fi

if [ -e "${NAME}" ]; then
  echo "${NAME} already exists" 1>&2
  exit 3
fi

mkdir -p ${NAME}
chown agladysh:users ${NAME}
chmod g+s ${NAME}
chmod g+w ${NAME}
pushd ${NAME} > /dev/null
sudo -u agladysh git init --bare
popd > /dev/null

