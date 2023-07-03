#!/usr/bin/env bash

LONGHORN_VERSION=${LONGHORN_VERSION:-1.4.2}

LOCAL_DIR=$(dirname "$0")
CONTENT_URL="https://raw.githubusercontent.com/longhorn/longhorn/v${LONGHORN_VERSION}/deploy/longhorn.yaml"

mkdir -p "$LOCAL_DIR/origin"
pushd "$LOCAL_DIR/origin" || exit $?

config_version=$(cat .config_version 2>/dev/null)
if [ "$LONGHORN_VERSION" == "$config_version" ]; then
	echo "Current config version is already $LONGHORN_VERSION, skip update"
	exit 0
fi

echo "Download longhorn.yaml ..."
wget -q -O longhorn.yaml "${CONTENT_URL}" || exit $?

echo "$LONGHORN_VERSION" >.config_version

popd || exit $?

# Ensure open-iscsi is installed
