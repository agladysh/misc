#!/bin/bash

set -e

APP=$1
ARTWORK=$2
DEST_IPA=$3

if [ -z "${APP}" -o -z "${ARTWORK}" -o -z "${DEST_IPA}" ]; then
  echo "Usage: $(basename $0) <.app> <iTunesArtwork> <generated .ipa>" >&2
  exit 1
fi

PAYLOAD_TMP=$(mktemp -d)

if [ ! -d "${APP}" ]; then
  echo "output .app not found: '${APP}'" >&2
  exit 1
fi

if [ ! -f "${ARTWORK}" ]; then
  echo "iTunes artwork not found: '${ARTWORK}'" >&2
  exit 1
fi

# TODO: Handle errors!

rm -rf ${PAYLOAD_TMP}
mkdir -p ${PAYLOAD_TMP}/Payload
cp -Rp ${APP} ${PAYLOAD_TMP}/Payload
cp ${ARTWORK} ${PAYLOAD_TMP}/iTunesArtwork
ditto -c -k ${PAYLOAD_TMP} ${DEST_IPA}
rm -rf ${PAYLOAD_TMP}
