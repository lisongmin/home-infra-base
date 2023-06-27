#!/bin/bash

LOCAL_DIR=$(dirname "$0")
source "${LOCAL_DIR}/envrc"

k3sup install \
  --cluster \
  --user "${K3S_USER}" \
  --host "${K3S_SERVER}" \
  --k3s-extra-args "${K3S_EXTRA_ARGS}" \
  --k3s-version "${K3S_VERSION}" || exit $?

if [ -n "${K3S_SERVERS_TO_JOIN}" ]; then
  read -ra servers_to_join <<<"$K3S_SERVERS_TO_JOIN"
  for server_to_join in "${servers_to_join[@]}"; do
    k3sup join \
      --server \
      --server_user "${K3S_USER}" \
      --server_host "${K3S_SERVER}" \
      --user "${K3S_USER}" \
      --host "${server_to_join}" \
      --k3s-extra-args "${K3S_EXTRA_ARGS}" \
      --k3s-version "${K3S_VERSION}" || exit $?
  done
fi

if [ -n "${K3S_AGENTS}" ]; then
  read -ra agents_to_join <<<"$K3S_AGENTS"
  for agent in "${agents_to_join[@]}"; do
    k3sup join \
      --server_user "${K3S_USER}" \
      --server_host "${K3S_SERVER}" \
      --user "${K3S_USER}" \
      --host "${agent}" \
      --k3s-extra-args "${K3S_EXTRA_ARGS}" \
      --k3s-version "${K3S_VERSION}" || exit $?
  done
fi
