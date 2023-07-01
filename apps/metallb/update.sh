#!/usr/bin/env bash

METALLB_VERSION=${METALLB_VERSION:-0.13.10}

LOCAL_DIR=$(dirname "$0")
CONTENT_URL="https://github.com/metallb/metallb/config/frr?ref=v${METALLB_VERSION}"

pushd "$LOCAL_DIR/origin" || exit $?

config_version=$(cat .config_version 2>/dev/null)
if [ "$METALLB_VERSION" = "$config_version" ]; then
	echo "Current config version is already $METALLB_VERSION, skip update"
	exit 0
fi

kustomize build "$CONTENT_URL" -o frr-config.yml || exit 1
echo "$METALLB_VERSION" >.config_version

popd || exit $?
